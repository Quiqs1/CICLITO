from typing import Annotated, Any

import oracledb
from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.database import get_db, row_as_dict, rows_as_dicts
from app.core.exceptions import handle_oracle_error
from app.core.security import require_roles
from app.schemas.operacion import DevolucionIn, EntregaIn, OrdenMantIn, OrdenMantPatchIn, RefaccionIn

router = APIRouter(prefix="/api/operacion", tags=["operacion"])
Staff = require_roles("EMPLEADO", "ADMINISTRADOR")


def _scalar(value):
    if isinstance(value, (list, tuple)):
        return value[0]
    return value


def _estado_bici(cursor, nombre: str) -> int:
    cursor.execute(
        "SELECT id_estado_bici AS id FROM estado_bicicleta WHERE nombre = :nombre",
        nombre=nombre,
    )
    row = row_as_dict(cursor)
    if row is None:
        raise HTTPException(status_code=500, detail=f"Estado de bicicleta no encontrado: {nombre}")
    return int(row["id"])


def _estado_res(cursor, nombre: str) -> int:
    cursor.execute(
        "SELECT id_estado_res AS id FROM estado_reserva WHERE nombre = :nombre",
        nombre=nombre,
    )
    row = row_as_dict(cursor)
    if row is None:
        raise HTTPException(status_code=500, detail=f"Estado de reserva no encontrado: {nombre}")
    return int(row["id"])


def _empleado_id(user: dict[str, Any]) -> int:
    if user.get("id_empleado") is None:
        raise HTTPException(status_code=400, detail="El usuario no tiene perfil de empleado.")
    return int(user["id_empleado"])


@router.get("/bicicletas")
def listar_bicicletas_operacion(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT b.id_bicicleta, b.codigo_interno, b.marca, b.modelo, eb.nombre AS estado
                FROM bicicleta b
                JOIN estado_bicicleta eb ON eb.id_estado_bici = b.id_estado_actual
                ORDER BY b.codigo_interno
                """
            )
            return rows_as_dicts(cursor)
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.get("/reservas")
def reservas_del_dia(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    try:
        sucursal = user.get("id_sucursal")
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT r.id_reserva, r.folio, er.nombre AS estado_reserva,
                       c.nombres || ' ' || c.apellidos AS cliente,
                       sr.nombre AS sucursal_recogida, sd.nombre AS sucursal_devolucion,
                       r.fecha_inicio_prog, r.fecha_fin_prog, r.fecha_recogida_real,
                       r.fecha_devolucion_real, r.total_estimado
                FROM reserva r
                JOIN estado_reserva er ON er.id_estado_res = r.id_estado_res
                JOIN cliente c ON c.id_cliente = r.id_cliente
                JOIN sucursal sr ON sr.id_sucursal = r.id_sucursal_recogida
                JOIN sucursal sd ON sd.id_sucursal = r.id_sucursal_devolucion
                WHERE (
                        TRUNC(r.fecha_inicio_prog) = TRUNC(SYSDATE)
                     OR TRUNC(r.fecha_fin_prog) = TRUNC(SYSDATE)
                     OR er.nombre = 'En curso'
                      )
                  AND (:id_sucursal IS NULL
                       OR r.id_sucursal_recogida = :id_sucursal
                       OR r.id_sucursal_devolucion = :id_sucursal)
                ORDER BY r.fecha_inicio_prog
                """,
                id_sucursal=sucursal,
            )
            reservas = rows_as_dicts(cursor)
            for reserva in reservas:
                cursor.execute(
                    """
                    SELECT dr.id_detalle_res, dr.id_bicicleta, b.codigo_interno, b.id_tipo,
                           tb.nombre AS tipo_bicicleta, dr.deposito_aplicado,
                           dr.precio_hora_aplicado, dr.subtotal, dr.recargo_retraso, dr.cargo_dano
                    FROM detalle_reserva dr
                    JOIN bicicleta b ON b.id_bicicleta = dr.id_bicicleta
                    JOIN tipo_bicicleta tb ON tb.id_tipo = b.id_tipo
                    WHERE dr.id_reserva = :id_reserva
                    """,
                    id_reserva=reserva["id_reserva"],
                )
                reserva["detalle"] = rows_as_dicts(cursor)
        return reservas
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.get("/puntos-inspeccion")
def puntos_inspeccion(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
    id_tipo: int = Query(...),
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT p.id_punto, p.nombre, p.descripcion
                FROM punto_inspeccion p
                JOIN punto_inspeccion_tipo pt ON pt.id_punto = p.id_punto
                WHERE pt.id_tipo = :id_tipo
                ORDER BY p.id_punto
                """,
                id_tipo=id_tipo,
            )
            return rows_as_dicts(cursor)
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


def _guardar_revision(cursor, id_bicicleta, id_empleado, id_reserva, tipo, checklist):
    id_rev = cursor.var(oracledb.NUMBER)
    cursor.execute(
        """
        INSERT INTO revision (
            id_bicicleta, id_empleado, id_reserva, tipo_revision, observaciones
        ) VALUES (
            :id_bicicleta, :id_empleado, :id_reserva, :tipo_revision, :observaciones
        )
        RETURNING id_revision INTO :id_revision
        """,
        id_bicicleta=id_bicicleta,
        id_empleado=id_empleado,
        id_reserva=id_reserva,
        tipo_revision=tipo,
        observaciones=checklist.observaciones,
        id_revision=id_rev,
    )
    id_revision = int(_scalar(id_rev.getvalue()))
    for punto in checklist.puntos:
        cursor.execute(
            """
            INSERT INTO detalle_revision (id_revision, id_punto, resultado, comentario)
            VALUES (:id_revision, :id_punto, :resultado, :comentario)
            """,
            id_revision=id_revision,
            id_punto=punto.id_punto,
            resultado=punto.resultado,
            comentario=punto.comentario,
        )
    return id_revision


@router.post("/reservas/{id_reserva}/entregar")
def entregar(
    id_reserva: int,
    payload: EntregaIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    id_empleado = _empleado_id(user)
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT r.id_reserva, er.nombre AS estado
                FROM reserva r
                JOIN estado_reserva er ON er.id_estado_res = r.id_estado_res
                WHERE r.id_reserva = :id_reserva
                """,
                id_reserva=id_reserva,
            )
            reserva = row_as_dict(cursor)
            if reserva is None:
                raise HTTPException(status_code=404, detail="Reserva no encontrada.")
            if reserva["estado"] not in ("Confirmada", "Pendiente de pago"):
                raise HTTPException(status_code=400, detail="La reserva no está lista para entrega.")
            id_en_renta = _estado_bici(cursor, "En renta")
            id_en_curso = _estado_res(cursor, "En curso")
            for checklist in payload.checklists:
                _guardar_revision(
                    cursor, checklist.id_bicicleta, id_empleado, id_reserva, "ENTREGA", checklist
                )
                cursor.execute(
                    "UPDATE bicicleta SET id_estado_actual = :estado WHERE id_bicicleta = :id_bici",
                    estado=id_en_renta,
                    id_bici=checklist.id_bicicleta,
                )
            cursor.execute(
                """
                UPDATE reserva
                   SET fecha_recogida_real = SYSDATE,
                       id_empleado_entrega = :id_empleado,
                       id_estado_res = :id_estado
                 WHERE id_reserva = :id_reserva
                """,
                id_empleado=id_empleado,
                id_estado=id_en_curso,
                id_reserva=id_reserva,
            )
        conn.commit()
        return {"ok": True}
    except HTTPException:
        conn.rollback()
        raise
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.post("/reservas/{id_reserva}/devolver")
def devolver(
    id_reserva: int,
    payload: DevolucionIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    id_empleado = _empleado_id(user)
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT r.id_reserva, r.id_sucursal_devolucion, r.fecha_fin_prog, er.nombre AS estado
                FROM reserva r
                JOIN estado_reserva er ON er.id_estado_res = r.id_estado_res
                WHERE r.id_reserva = :id_reserva
                """,
                id_reserva=id_reserva,
            )
            reserva = row_as_dict(cursor)
            if reserva is None:
                raise HTTPException(status_code=404, detail="Reserva no encontrada.")
            if reserva["estado"] != "En curso":
                raise HTTPException(status_code=400, detail="Solo se pueden devolver reservas en curso.")
            id_disponible = _estado_bici(cursor, "Disponible")
            id_fuera = _estado_bici(cursor, "Fuera de servicio")
            id_finalizada = _estado_res(cursor, "Finalizada")
            total_recargos = 0.0
            total_danos = 0.0
            total_depositos = 0.0
            for checklist in payload.checklists:
                cursor.execute(
                    """
                    SELECT dr.id_detalle_res, dr.precio_hora_aplicado, dr.deposito_aplicado
                    FROM detalle_reserva dr
                    WHERE dr.id_reserva = :id_reserva AND dr.id_bicicleta = :id_bicicleta
                    """,
                    id_reserva=id_reserva,
                    id_bicicleta=checklist.id_bicicleta,
                )
                detalle = row_as_dict(cursor)
                if detalle is None:
                    raise HTTPException(status_code=400, detail="La bicicleta no pertenece a la reserva.")
                cursor.execute(
                    """
                    SELECT GREATEST(CEIL((SYSDATE - fecha_fin_prog) * 24), 0) AS horas
                    FROM reserva
                    WHERE id_reserva = :id_reserva
                    """,
                    id_reserva=id_reserva,
                )
                horas_retraso = int(row_as_dict(cursor)["horas"] or 0)
                recargo = round(horas_retraso * float(detalle["precio_hora_aplicado"]), 2)
                cargo = float(checklist.cargo_dano)
                total_recargos += recargo
                total_danos += cargo
                total_depositos += float(detalle["deposito_aplicado"])
                cursor.execute(
                    """
                    UPDATE detalle_reserva
                       SET recargo_retraso = :recargo, cargo_dano = :cargo
                     WHERE id_detalle_res = :id_detalle
                    """,
                    recargo=recargo,
                    cargo=cargo,
                    id_detalle=detalle["id_detalle_res"],
                )
                _guardar_revision(
                    cursor,
                    checklist.id_bicicleta,
                    id_empleado,
                    id_reserva,
                    "DEVOLUCION",
                    checklist,
                )
                cursor.execute(
                    "SELECT id_estado_actual FROM bicicleta WHERE id_bicicleta = :id_bici",
                    id_bici=checklist.id_bicicleta,
                )
                estado_actual = int(row_as_dict(cursor)["id_estado_actual"])
                nuevo_estado = id_disponible if estado_actual != id_fuera else id_fuera
                cursor.execute(
                    """
                    UPDATE bicicleta
                       SET id_estado_actual = :estado, id_sucursal_actual = :sucursal
                     WHERE id_bicicleta = :id_bici
                    """,
                    estado=nuevo_estado,
                    sucursal=reserva["id_sucursal_devolucion"],
                    id_bici=checklist.id_bicicleta,
                )
            cursor.execute(
                """
                UPDATE reserva
                   SET fecha_devolucion_real = SYSDATE,
                       id_empleado_devolucion = :id_empleado,
                       id_estado_res = :id_estado
                 WHERE id_reserva = :id_reserva
                """,
                id_empleado=id_empleado,
                id_estado=id_finalizada,
                id_reserva=id_reserva,
            )
            if total_recargos > 0:
                cursor.execute(
                    """
                    INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
                    VALUES (:id_reserva, :id_empleado, 'EFECTIVO', 'RECARGO_RETRASO', :monto, 'DEVOLUCION')
                    """,
                    id_reserva=id_reserva,
                    id_empleado=id_empleado,
                    monto=total_recargos,
                )
            if total_danos > 0:
                cursor.execute(
                    """
                    INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
                    VALUES (:id_reserva, :id_empleado, 'EFECTIVO', 'CARGO_DANO', :monto, 'DEVOLUCION')
                    """,
                    id_reserva=id_reserva,
                    id_empleado=id_empleado,
                    monto=total_danos,
                )
            deposito_neto = round(total_depositos - total_danos, 2)
            if deposito_neto > 0:
                cursor.execute(
                    """
                    INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
                    VALUES (:id_reserva, :id_empleado, 'EFECTIVO', 'DEVOLUCION_DEPOSITO', :monto, 'CIERRE')
                    """,
                    id_reserva=id_reserva,
                    id_empleado=id_empleado,
                    monto=deposito_neto,
                )
        conn.commit()
        return {
            "ok": True,
            "recargo_retraso": total_recargos,
            "cargo_dano": total_danos,
            "deposito_devuelto": max(deposito_neto, 0),
        }
    except HTTPException:
        conn.rollback()
        raise
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.get("/mantenimiento")
def listar_ordenes(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT om.id_orden, om.id_bicicleta, b.codigo_interno, b.marca, b.modelo,
                       om.diagnostico, om.descripcion_trabajo, om.costo_mano_obra,
                       om.fecha_inicio, om.fecha_fin, om.estado_orden,
                       e.nombres || ' ' || e.apellidos AS mecanico
                FROM orden_mantenimiento om
                JOIN bicicleta b ON b.id_bicicleta = om.id_bicicleta
                JOIN empleado e ON e.id_empleado = om.id_empleado
                ORDER BY om.fecha_inicio DESC
                """
            )
            ordenes = rows_as_dicts(cursor)
            for orden in ordenes:
                cursor.execute(
                    """
                    SELECT id_detalle_mant, nombre_refaccion, cantidad, costo_unitario
                    FROM detalle_mantenimiento
                    WHERE id_orden = :id_orden
                    """,
                    id_orden=orden["id_orden"],
                )
                orden["refacciones"] = rows_as_dicts(cursor)
        return ordenes
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.post("/mantenimiento")
def crear_orden(
    payload: OrdenMantIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    id_empleado = _empleado_id(user)
    try:
        with conn.cursor() as cursor:
            id_orden = cursor.var(oracledb.NUMBER)
            cursor.execute(
                """
                INSERT INTO orden_mantenimiento (
                    id_bicicleta, id_empleado, id_revision_origen, diagnostico,
                    descripcion_trabajo, costo_mano_obra, estado_orden
                ) VALUES (
                    :id_bicicleta, :id_empleado, :id_revision_origen, :diagnostico,
                    :descripcion_trabajo, :costo_mano_obra, 'ABIERTA'
                )
                RETURNING id_orden INTO :id_orden
                """,
                id_bicicleta=payload.id_bicicleta,
                id_empleado=id_empleado,
                id_revision_origen=payload.id_revision_origen,
                diagnostico=payload.diagnostico,
                descripcion_trabajo=payload.descripcion_trabajo,
                costo_mano_obra=payload.costo_mano_obra,
                id_orden=id_orden,
            )
            id_mant = _estado_bici(cursor, "En mantenimiento")
            cursor.execute(
                "UPDATE bicicleta SET id_estado_actual = :estado WHERE id_bicicleta = :id_bici",
                estado=id_mant,
                id_bici=payload.id_bicicleta,
            )
        conn.commit()
        return {"id_orden": int(_scalar(id_orden.getvalue()))}
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.patch("/mantenimiento/{id_orden}")
def actualizar_orden(
    id_orden: int,
    payload: OrdenMantPatchIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT id_orden, id_bicicleta, estado_orden FROM orden_mantenimiento WHERE id_orden = :id",
                id=id_orden,
            )
            orden = row_as_dict(cursor)
            if orden is None:
                raise HTTPException(status_code=404, detail="Orden no encontrada.")
            estado = payload.estado_orden or orden["estado_orden"]
            cursor.execute(
                """
                UPDATE orden_mantenimiento
                   SET estado_orden = :estado,
                       descripcion_trabajo = NVL(:descripcion, descripcion_trabajo),
                       costo_mano_obra = NVL(:costo, costo_mano_obra),
                       fecha_fin = CASE WHEN :estado = 'CERRADA' THEN NVL(fecha_fin, SYSDATE) ELSE fecha_fin END
                 WHERE id_orden = :id_orden
                """,
                estado=estado,
                descripcion=payload.descripcion_trabajo,
                costo=payload.costo_mano_obra,
                id_orden=id_orden,
            )
            if estado == "CERRADA":
                id_disponible = _estado_bici(cursor, "Disponible")
                cursor.execute(
                    "UPDATE bicicleta SET id_estado_actual = :estado WHERE id_bicicleta = :id_bici",
                    estado=id_disponible,
                    id_bici=orden["id_bicicleta"],
                )
        conn.commit()
        return {"ok": True}
    except HTTPException:
        conn.rollback()
        raise
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.post("/mantenimiento/{id_orden}/refacciones")
def agregar_refaccion(
    id_orden: int,
    payload: RefaccionIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Staff)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO detalle_mantenimiento (id_orden, nombre_refaccion, cantidad, costo_unitario)
                VALUES (:id_orden, :nombre, :cantidad, :costo)
                """,
                id_orden=id_orden,
                nombre=payload.nombre_refaccion,
                cantidad=payload.cantidad,
                costo=payload.costo_unitario,
            )
        conn.commit()
        return {"ok": True}
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc
