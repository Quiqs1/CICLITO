from typing import Annotated, Any

import oracledb
from fastapi import APIRouter, Depends, HTTPException

from app.core.database import get_db, row_as_dict, rows_as_dicts
from app.core.exceptions import handle_oracle_error
from app.core.security import require_roles
from app.schemas.reservas import PagoIn, ReservaCreateIn, ReservaCreadaOut

router = APIRouter(prefix="/api/reservas", tags=["reservas"])


def _scalar(value):
    if isinstance(value, (list, tuple)):
        return value[0]
    return value


def _estado_id(cursor, tabla: str, nombre: str) -> int:
    if tabla == "estado_reserva":
        cursor.execute(
            "SELECT id_estado_res AS id FROM estado_reserva WHERE nombre = :nombre",
            nombre=nombre,
        )
    else:
        cursor.execute(
            "SELECT id_estado_bici AS id FROM estado_bicicleta WHERE nombre = :nombre",
            nombre=nombre,
        )
    row = row_as_dict(cursor)
    if row is None:
        raise HTTPException(status_code=500, detail=f"Catálogo incompleto: {nombre}")
    return int(row["id"])


@router.post("", response_model=ReservaCreadaOut)
def crear_reserva(
    payload: ReservaCreateIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(require_roles("CLIENTE"))],
):
    if user.get("id_cliente") is None:
        raise HTTPException(status_code=400, detail="El usuario no tiene perfil de cliente.")
    try:
        with conn.cursor() as cursor:
            lista_tipo = conn.gettype("SYS.ODCINUMBERLIST")
            ids = lista_tipo.newobject()
            ids.extend(payload.ids_bicicletas)
            id_out = cursor.var(oracledb.NUMBER)
            folio_out = cursor.var(oracledb.DB_TYPE_VARCHAR)
            cursor.callproc(
                "sp_crear_reserva",
                [
                    int(user["id_cliente"]),
                    payload.id_sucursal_recogida,
                    payload.id_sucursal_devolucion,
                    payload.fecha_inicio.replace(tzinfo=None),
                    payload.fecha_fin.replace(tzinfo=None),
                    ids,
                    id_out,
                    folio_out,
                ],
            )
        return ReservaCreadaOut(
            id_reserva=int(_scalar(id_out.getvalue())),
            folio=str(_scalar(folio_out.getvalue())),
        )
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.get("/mias")
def mis_reservas(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(require_roles("CLIENTE"))],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT *
                FROM vw_resumen_reservas
                WHERE correo_cliente = :correo
                ORDER BY fecha_inicio_prog DESC
                """,
                correo=user["correo"],
            )
            reservas = rows_as_dicts(cursor)
            for reserva in reservas:
                cursor.execute(
                    """
                    SELECT dr.id_detalle_res, dr.id_bicicleta, b.codigo_interno,
                           dr.precio_hora_aplicado, dr.precio_dia_aplicado, dr.deposito_aplicado,
                           dr.dias_cobrados, dr.horas_cobradas, dr.subtotal,
                           dr.recargo_retraso, dr.cargo_dano
                    FROM detalle_reserva dr
                    JOIN bicicleta b ON b.id_bicicleta = dr.id_bicicleta
                    WHERE dr.id_reserva = :id_reserva
                    """,
                    id_reserva=reserva["id_reserva"],
                )
                reserva["detalle"] = rows_as_dicts(cursor)
                cursor.execute(
                    """
                    SELECT id_pago, metodo_pago, concepto_pago, monto, fecha_hora, referencia
                    FROM pago
                    WHERE id_reserva = :id_reserva
                    ORDER BY fecha_hora
                    """,
                    id_reserva=reserva["id_reserva"],
                )
                reserva["pagos"] = rows_as_dicts(cursor)
        return reservas
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.post("/{id_reserva}/cancelar")
def cancelar_reserva(
    id_reserva: int,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(require_roles("CLIENTE"))],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT r.id_reserva, r.id_cliente, er.nombre AS estado
                FROM reserva r
                JOIN estado_reserva er ON er.id_estado_res = r.id_estado_res
                WHERE r.id_reserva = :id_reserva
                """,
                id_reserva=id_reserva,
            )
            reserva = row_as_dict(cursor)
            if reserva is None:
                raise HTTPException(status_code=404, detail="Reserva no encontrada.")
            if int(reserva["id_cliente"]) != int(user["id_cliente"]):
                raise HTTPException(status_code=403, detail="No puede cancelar esta reserva.")
            if reserva["estado"] in ("En curso", "Finalizada", "Cancelada"):
                raise HTTPException(
                    status_code=400,
                    detail="La reserva ya no puede cancelarse en su estado actual.",
                )
            id_cancelada = _estado_id(cursor, "estado_reserva", "Cancelada")
            id_disponible = _estado_id(cursor, "estado_bicicleta", "Disponible")
            cursor.execute(
                """
                UPDATE reserva
                   SET id_estado_res = :id_estado, fecha_cancelacion = SYSDATE
                 WHERE id_reserva = :id_reserva
                """,
                id_estado=id_cancelada,
                id_reserva=id_reserva,
            )
            cursor.execute(
                """
                UPDATE bicicleta
                   SET id_estado_actual = :id_disponible
                 WHERE id_bicicleta IN (
                    SELECT id_bicicleta FROM detalle_reserva WHERE id_reserva = :id_reserva
                 )
                """,
                id_disponible=id_disponible,
                id_reserva=id_reserva,
            )
            cursor.execute(
                """
                SELECT NVL(SUM(
                    CASE
                        WHEN concepto_pago = 'ANTICIPO' THEN monto
                        WHEN concepto_pago = 'REEMBOLSO_ANTICIPO' THEN -monto
                        ELSE 0
                    END
                ), 0) AS saldo_anticipo
                FROM pago
                WHERE id_reserva = :id_reserva
                """,
                id_reserva=id_reserva,
            )
            saldo = float(row_as_dict(cursor)["saldo_anticipo"])
            if saldo > 0:
                cursor.execute(
                    """
                    INSERT INTO pago (id_reserva, metodo_pago, concepto_pago, monto, referencia)
                    VALUES (:id_reserva, 'TRANSFERENCIA', 'REEMBOLSO_ANTICIPO', :monto, 'CANCELACION')
                    """,
                    id_reserva=id_reserva,
                    monto=saldo,
                )
        conn.commit()
        return {"ok": True, "reembolso_anticipo": saldo if saldo > 0 else 0}
    except HTTPException:
        conn.rollback()
        raise
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.post("/{id_reserva}/pagos")
def registrar_pago(
    id_reserva: int,
    payload: PagoIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(require_roles("CLIENTE", "EMPLEADO", "ADMINISTRADOR"))],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT r.id_reserva, r.id_cliente, er.nombre AS estado
                FROM reserva r
                JOIN estado_reserva er ON er.id_estado_res = r.id_estado_res
                WHERE r.id_reserva = :id_reserva
                """,
                id_reserva=id_reserva,
            )
            reserva = row_as_dict(cursor)
            if reserva is None:
                raise HTTPException(status_code=404, detail="Reserva no encontrada.")
            if user["rol"] == "CLIENTE" and int(reserva["id_cliente"]) != int(user["id_cliente"]):
                raise HTTPException(status_code=403, detail="No puede pagar esta reserva.")
            if reserva["estado"] in ("Cancelada", "Finalizada"):
                raise HTTPException(status_code=400, detail="La reserva no admite pagos.")
            cursor.execute(
                """
                INSERT INTO pago (
                    id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia
                ) VALUES (
                    :id_reserva, :id_empleado, :metodo_pago, :concepto_pago, :monto, :referencia
                )
                """,
                id_reserva=id_reserva,
                id_empleado=user.get("id_empleado"),
                metodo_pago=payload.metodo_pago,
                concepto_pago=payload.concepto_pago,
                monto=payload.monto,
                referencia=payload.referencia,
            )
            if payload.concepto_pago in ("ANTICIPO", "SALDO_RENTA", "DEPOSITO") and reserva[
                "estado"
            ] == "Pendiente de pago":
                id_confirmada = _estado_id(cursor, "estado_reserva", "Confirmada")
                cursor.execute(
                    "UPDATE reserva SET id_estado_res = :id_estado WHERE id_reserva = :id_reserva",
                    id_estado=id_confirmada,
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
