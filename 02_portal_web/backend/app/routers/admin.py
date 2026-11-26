from typing import Annotated, Any

import oracledb
from fastapi import APIRouter, Depends, HTTPException

from app.core.database import get_db, row_as_dict, rows_as_dicts
from app.core.exceptions import handle_oracle_error
from app.core.security import require_roles
from app.schemas.admin import BicicletaIn, TarifaIn, TemporadaIn, UsuarioEstadoIn

router = APIRouter(prefix="/api/admin", tags=["admin"])
Admin = require_roles("ADMINISTRADOR")


def _scalar(value):
    if isinstance(value, (list, tuple)):
        return value[0]
    return value


@router.get("/flota")
def listar_flota(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT b.id_bicicleta, b.codigo_interno, b.num_serie, b.id_tipo, tb.nombre AS tipo,
                       b.id_estado_actual, eb.nombre AS estado, b.id_sucursal_actual,
                       s.nombre AS sucursal, b.marca, b.modelo, b.rodada, b.talla_cuadro,
                       b.color, b.anio, b.fecha_adquisicion, b.costo_adquisicion, b.foto_url,
                       be.autonomia_km, be.capacidad_bateria_wh
                FROM bicicleta b
                JOIN tipo_bicicleta tb ON tb.id_tipo = b.id_tipo
                JOIN estado_bicicleta eb ON eb.id_estado_bici = b.id_estado_actual
                JOIN sucursal s ON s.id_sucursal = b.id_sucursal_actual
                LEFT JOIN bicicleta_electrica be ON be.id_bicicleta = b.id_bicicleta
                ORDER BY b.codigo_interno
                """
            )
            return rows_as_dicts(cursor)
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.get("/catalogos")
def catalogos_admin(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id_tipo, nombre FROM tipo_bicicleta ORDER BY nombre")
            tipos = rows_as_dicts(cursor)
            cursor.execute("SELECT id_estado_bici, nombre FROM estado_bicicleta ORDER BY id_estado_bici")
            estados = rows_as_dicts(cursor)
            cursor.execute("SELECT id_sucursal, nombre FROM sucursal ORDER BY nombre")
            sucursales = rows_as_dicts(cursor)
        return {"tipos": tipos, "estados": estados, "sucursales": sucursales}
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.post("/flota")
def alta_bicicleta(
    payload: BicicletaIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            id_var = cursor.var(oracledb.NUMBER)
            cursor.execute(
                """
                INSERT INTO bicicleta (
                    codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual,
                    marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion,
                    costo_adquisicion, foto_url
                ) VALUES (
                    :codigo_interno, :num_serie, :id_tipo, :id_estado_actual, :id_sucursal_actual,
                    :marca, :modelo, :rodada, :talla_cuadro, :color, :anio, :fecha_adquisicion,
                    :costo_adquisicion, :foto_url
                )
                RETURNING id_bicicleta INTO :id_bicicleta
                """,
                codigo_interno=payload.codigo_interno,
                num_serie=payload.num_serie,
                id_tipo=payload.id_tipo,
                id_estado_actual=payload.id_estado_actual,
                id_sucursal_actual=payload.id_sucursal_actual,
                marca=payload.marca,
                modelo=payload.modelo,
                rodada=payload.rodada,
                talla_cuadro=payload.talla_cuadro,
                color=payload.color,
                anio=payload.anio,
                fecha_adquisicion=payload.fecha_adquisicion,
                costo_adquisicion=payload.costo_adquisicion,
                foto_url=payload.foto_url,
                id_bicicleta=id_var,
            )
            id_bici = int(_scalar(id_var.getvalue()))
            if payload.autonomia_km and payload.capacidad_bateria_wh:
                cursor.execute(
                    """
                    INSERT INTO bicicleta_electrica (id_bicicleta, autonomia_km, capacidad_bateria_wh)
                    VALUES (:id_bicicleta, :autonomia_km, :capacidad_bateria_wh)
                    """,
                    id_bicicleta=id_bici,
                    autonomia_km=payload.autonomia_km,
                    capacidad_bateria_wh=payload.capacidad_bateria_wh,
                )
        conn.commit()
        return {"id_bicicleta": id_bici}
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.patch("/flota/{id_bicicleta}")
def editar_bicicleta(
    id_bicicleta: int,
    payload: BicicletaIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                UPDATE bicicleta SET
                    codigo_interno = :codigo_interno,
                    num_serie = :num_serie,
                    id_tipo = :id_tipo,
                    id_estado_actual = :id_estado_actual,
                    id_sucursal_actual = :id_sucursal_actual,
                    marca = :marca,
                    modelo = :modelo,
                    rodada = :rodada,
                    talla_cuadro = :talla_cuadro,
                    color = :color,
                    anio = :anio,
                    fecha_adquisicion = :fecha_adquisicion,
                    costo_adquisicion = :costo_adquisicion,
                    foto_url = :foto_url
                WHERE id_bicicleta = :id_bicicleta
                """,
                codigo_interno=payload.codigo_interno,
                num_serie=payload.num_serie,
                id_tipo=payload.id_tipo,
                id_estado_actual=payload.id_estado_actual,
                id_sucursal_actual=payload.id_sucursal_actual,
                marca=payload.marca,
                modelo=payload.modelo,
                rodada=payload.rodada,
                talla_cuadro=payload.talla_cuadro,
                color=payload.color,
                anio=payload.anio,
                fecha_adquisicion=payload.fecha_adquisicion,
                costo_adquisicion=payload.costo_adquisicion,
                foto_url=payload.foto_url,
                id_bicicleta=id_bicicleta,
            )
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Bicicleta no encontrada.")
            if payload.autonomia_km and payload.capacidad_bateria_wh:
                cursor.execute(
                    """
                    MERGE INTO bicicleta_electrica be
                    USING (SELECT :id_bicicleta AS id_bicicleta FROM dual) src
                       ON (be.id_bicicleta = src.id_bicicleta)
                    WHEN MATCHED THEN UPDATE SET
                        autonomia_km = :autonomia_km,
                        capacidad_bateria_wh = :capacidad_bateria_wh
                    WHEN NOT MATCHED THEN INSERT (id_bicicleta, autonomia_km, capacidad_bateria_wh)
                    VALUES (:id_bicicleta, :autonomia_km, :capacidad_bateria_wh)
                    """,
                    id_bicicleta=id_bicicleta,
                    autonomia_km=payload.autonomia_km,
                    capacidad_bateria_wh=payload.capacidad_bateria_wh,
                )
        conn.commit()
        return {"ok": True}
    except HTTPException:
        conn.rollback()
        raise
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.get("/tarifas")
def listar_tarifas(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT t.id_tarifa, t.id_tipo, tb.nombre AS tipo, t.precio_hora, t.precio_dia,
                       t.vigente_desde, t.vigente_hasta
                FROM tarifa t
                JOIN tipo_bicicleta tb ON tb.id_tipo = t.id_tipo
                ORDER BY tb.nombre, t.vigente_desde DESC
                """
            )
            tarifas = rows_as_dicts(cursor)
            cursor.execute(
                """
                SELECT id_temporada, nombre, fecha_inicio, fecha_fin, porcentaje_incremento
                FROM temporada
                ORDER BY fecha_inicio
                """
            )
            temporadas = rows_as_dicts(cursor)
        return {"tarifas": tarifas, "temporadas": temporadas}
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.post("/tarifas")
def crear_tarifa(
    payload: TarifaIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
                VALUES (:id_tipo, :precio_hora, :precio_dia, :vigente_desde, :vigente_hasta)
                """,
                id_tipo=payload.id_tipo,
                precio_hora=payload.precio_hora,
                precio_dia=payload.precio_dia,
                vigente_desde=payload.vigente_desde,
                vigente_hasta=payload.vigente_hasta,
            )
        conn.commit()
        return {"ok": True}
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.post("/temporadas")
def crear_temporada(
    payload: TemporadaIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO temporada (nombre, fecha_inicio, fecha_fin, porcentaje_incremento)
                VALUES (:nombre, :fecha_inicio, :fecha_fin, :porcentaje_incremento)
                """,
                nombre=payload.nombre,
                fecha_inicio=payload.fecha_inicio,
                fecha_fin=payload.fecha_fin,
                porcentaje_incremento=payload.porcentaje_incremento,
            )
        conn.commit()
        return {"ok": True}
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.get("/usuarios")
def listar_usuarios(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT u.id_usuario, u.rol, u.correo, u.estado_cuenta, u.fecha_alta, u.ultimo_acceso,
                       e.id_empleado, e.nombres AS empleado_nombres, e.apellidos AS empleado_apellidos,
                       e.puesto, s.nombre AS sucursal
                FROM usuario u
                LEFT JOIN empleado e ON e.id_usuario = u.id_usuario
                LEFT JOIN sucursal s ON s.id_sucursal = e.id_sucursal
                ORDER BY u.rol, u.correo
                """
            )
            return rows_as_dicts(cursor)
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc


@router.patch("/usuarios/{id_usuario}")
def actualizar_usuario(
    id_usuario: int,
    payload: UsuarioEstadoIn,
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "UPDATE usuario SET estado_cuenta = :estado WHERE id_usuario = :id_usuario",
                estado=payload.estado_cuenta,
                id_usuario=id_usuario,
            )
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Usuario no encontrado.")
        conn.commit()
        return {"ok": True}
    except HTTPException:
        conn.rollback()
        raise
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.get("/reportes/ingresos")
def reportes_ingresos(
    conn: Annotated[oracledb.Connection, Depends(get_db)],
    user: Annotated[dict[str, Any], Depends(Admin)],
):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT id_sucursal, sucursal, anio_mes, ingresos_brutos, reembolsos, ingreso_neto
                FROM vw_ingresos_sucursal_mes
                ORDER BY anio_mes DESC, ingreso_neto DESC
                """
            )
            ingresos = rows_as_dicts(cursor)
            cursor.execute(
                """
                SELECT tb.nombre AS tipo_bicicleta,
                       COUNT(dr.id_detalle_res) AS veces_rentada,
                       NVL(SUM(dr.subtotal), 0) AS ingreso_base
                FROM tipo_bicicleta tb
                LEFT JOIN bicicleta b ON b.id_tipo = tb.id_tipo
                LEFT JOIN detalle_reserva dr ON dr.id_bicicleta = b.id_bicicleta
                GROUP BY tb.nombre
                ORDER BY ingreso_base DESC
                """
            )
            rentabilidad = rows_as_dicts(cursor)
            cursor.execute(
                """
                SELECT h.id_historial, b.codigo_interno, ea.nombre AS estado_anterior,
                       en.nombre AS estado_nuevo, h.fecha_hora, h.motivo
                FROM historial_estado_bici h
                JOIN bicicleta b ON b.id_bicicleta = h.id_bicicleta
                LEFT JOIN estado_bicicleta ea ON ea.id_estado_bici = h.id_estado_anterior
                JOIN estado_bicicleta en ON en.id_estado_bici = h.id_estado_nuevo
                ORDER BY h.fecha_hora DESC
                FETCH FIRST 80 ROWS ONLY
                """
            )
            historial = rows_as_dicts(cursor)
        return {
            "ingresos": ingresos,
            "rentabilidad": rentabilidad,
            "historial": historial,
        }
    except oracledb.DatabaseError as exc:
        raise handle_oracle_error(exc) from exc
