from datetime import datetime
from typing import Annotated

import oracledb
from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.core.database import get_db, row_as_dict, rows_as_dicts
from app.core.exceptions import handle_oracle_error
from app.schemas.catalogo import CotizacionIn, CotizacionOut

router = APIRouter(prefix="/api/catalogo", tags=["catalogo"])


@router.get("/sucursales")
def listar_sucursales(conn: Annotated[oracledb.Connection, Depends(get_db)]):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT id_sucursal, nombre, direccion, colonia_barrio, telefono, latitud, longitud
                FROM sucursal
                ORDER BY nombre
                """
            )
            sucursales = rows_as_dicts(cursor)
            cursor.execute(
                """
                SELECT id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre
                FROM horario_sucursal
                ORDER BY id_sucursal, dia_semana
                """
            )
            horarios = rows_as_dicts(cursor)
        by_id: dict[int, list] = {}
        for item in horarios:
            by_id.setdefault(item["id_sucursal"], []).append(item)
        for sucursal in sucursales:
            sucursal["horarios"] = by_id.get(sucursal["id_sucursal"], [])
        return sucursales
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.get("/tipos")
def listar_tipos(conn: Annotated[oracledb.Connection, Depends(get_db)]):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    tb.id_tipo, tb.nombre, tb.descripcion, tb.deposito_garantia,
                    tb.edad_estatura_recomendada, t.precio_hora, t.precio_dia
                FROM tipo_bicicleta tb
                LEFT JOIN tarifa t ON t.id_tarifa = (
                    SELECT t2.id_tarifa
                    FROM tarifa t2
                    WHERE t2.id_tipo = tb.id_tipo
                      AND t2.vigente_desde <= TRUNC(SYSDATE)
                      AND (t2.vigente_hasta IS NULL OR t2.vigente_hasta >= TRUNC(SYSDATE))
                    FETCH FIRST 1 ROW ONLY
                )
                ORDER BY tb.nombre
                """
            )
            return rows_as_dicts(cursor)
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.get("/paises")
def listar_paises(conn: Annotated[oracledb.Connection, Depends(get_db)]):
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id_pais, nombre, codigo_iso FROM pais ORDER BY nombre")
            return rows_as_dicts(cursor)
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.get("/disponibilidad")
def disponibilidad(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    fecha_inicio: datetime = Query(...),
    fecha_fin: datetime = Query(...),
    id_sucursal: int | None = None,
    id_tipo: int | None = None,
):
    if fecha_fin <= fecha_inicio:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La fecha de fin debe ser posterior a la fecha de inicio.",
        )
    try:
        sql = """
            SELECT
                v.id_bicicleta, v.codigo_interno, v.num_serie, v.tipo_bicicleta, v.marca, v.modelo,
                v.rodada, v.talla_cuadro, v.color, v.id_sucursal, v.sucursal_actual, v.estado_actual,
                v.precio_hora, v.precio_dia, v.deposito_garantia, v.autonomia_km,
                v.capacidad_bateria_wh, b.foto_url, b.id_tipo
            FROM vw_flota_disponible v
            JOIN bicicleta b ON b.id_bicicleta = v.id_bicicleta
            WHERE NOT EXISTS (
                SELECT 1
                FROM detalle_reserva dr
                JOIN reserva r ON r.id_reserva = dr.id_reserva
                JOIN estado_reserva er ON er.id_estado_res = r.id_estado_res
                WHERE dr.id_bicicleta = v.id_bicicleta
                  AND er.bloquea_inventario = 'S'
                  AND :fecha_inicio < r.fecha_fin_prog
                  AND :fecha_fin > r.fecha_inicio_prog
            )
        """
        params: dict = {
            "fecha_inicio": fecha_inicio.replace(tzinfo=None),
            "fecha_fin": fecha_fin.replace(tzinfo=None),
        }
        if id_sucursal is not None:
            sql += " AND v.id_sucursal = :id_sucursal"
            params["id_sucursal"] = id_sucursal
        if id_tipo is not None:
            sql += " AND b.id_tipo = :id_tipo"
            params["id_tipo"] = id_tipo
        sql += " ORDER BY v.sucursal_actual, v.tipo_bicicleta, v.codigo_interno"
        with conn.cursor() as cursor:
            cursor.execute(sql, params)
            return rows_as_dicts(cursor)
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.post("/cotizar", response_model=CotizacionOut)
def cotizar(payload: CotizacionIn, conn: Annotated[oracledb.Connection, Depends(get_db)]):
    try:
        with conn.cursor() as cursor:
            costo_unitario = cursor.callfunc(
                "fn_calcular_costo_bici",
                oracledb.NUMBER,
                [
                    payload.id_tipo,
                    payload.fecha_inicio.replace(tzinfo=None),
                    payload.fecha_fin.replace(tzinfo=None),
                ],
            )
            cursor.execute(
                "SELECT deposito_garantia FROM tipo_bicicleta WHERE id_tipo = :id_tipo",
                {"id_tipo": payload.id_tipo},
            )
            tipo = row_as_dict(cursor)
            if tipo is None:
                raise HTTPException(status_code=404, detail="Tipo de bicicleta no encontrado.")
            cursor.execute(
                """
                SELECT nombre, porcentaje_incremento
                FROM temporada
                WHERE TRUNC(:fecha) BETWEEN fecha_inicio AND fecha_fin
                FETCH FIRST 1 ROW ONLY
                """,
                {"fecha": payload.fecha_inicio.replace(tzinfo=None)},
            )
            temporada = row_as_dict(cursor)
        costo = float(costo_unitario)
        deposito = float(tipo["deposito_garantia"])
        return CotizacionOut(
            id_tipo=payload.id_tipo,
            cantidad=payload.cantidad,
            costo_unitario=costo,
            costo_total=round(costo * payload.cantidad, 2),
            deposito_unitario=deposito,
            deposito_total=round(deposito * payload.cantidad, 2),
            temporada_aplicada=temporada["nombre"] if temporada else "Temporada Regular",
            porcentaje_incremento=float(temporada["porcentaje_incremento"]) if temporada else 0,
        )
    except HTTPException:
        raise
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc
