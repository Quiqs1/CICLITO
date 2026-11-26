from typing import Annotated, Any

import oracledb
from fastapi import APIRouter, Depends, HTTPException, status

from app.core.database import get_db, row_as_dict
from app.core.exceptions import handle_oracle_error
from app.core.security import (
    create_access_token,
    get_current_user,
    hash_password,
    verify_password,
)
from app.schemas.auth import LoginIn, PerfilOut, RegistroIn, TokenOut

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/registro", response_model=TokenOut, status_code=status.HTTP_201_CREATED)
def _scalar(value):
    if isinstance(value, (list, tuple)):
        return value[0]
    return value


def registro(payload: RegistroIn, conn: Annotated[oracledb.Connection, Depends(get_db)]):
    try:
        correo = payload.correo.lower()
        with conn.cursor() as cursor:
            id_usuario_var = cursor.var(oracledb.NUMBER)
            cursor.execute(
                """
                INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
                VALUES ('CLIENTE', :correo, :password_hash, 'ACTIVA')
                RETURNING id_usuario INTO :id_usuario
                """,
                correo=correo,
                password_hash=hash_password(payload.password),
                id_usuario=id_usuario_var,
            )
            id_usuario = int(_scalar(id_usuario_var.getvalue()))
            id_cliente_var = cursor.var(oracledb.NUMBER)
            cursor.execute(
                """
                INSERT INTO cliente (
                    id_usuario, id_pais, tipo_identificacion, numero_identificacion,
                    nombres, apellidos, telefono, fecha_nacimiento
                ) VALUES (
                    :id_usuario, :id_pais, :tipo_identificacion, :numero_identificacion,
                    :nombres, :apellidos, :telefono, :fecha_nacimiento
                )
                RETURNING id_cliente INTO :id_cliente
                """,
                id_usuario=id_usuario,
                id_pais=payload.id_pais,
                tipo_identificacion=payload.tipo_identificacion,
                numero_identificacion=payload.numero_identificacion,
                nombres=payload.nombres,
                apellidos=payload.apellidos,
                telefono=payload.telefono,
                fecha_nacimiento=payload.fecha_nacimiento,
                id_cliente=id_cliente_var,
            )
            id_cliente = int(_scalar(id_cliente_var.getvalue()))
            cursor.execute(
                """
                INSERT INTO contacto_emergencia (id_cliente, nombre_completo, parentesco, telefono)
                VALUES (:id_cliente, :nombre_completo, :parentesco, :telefono)
                """,
                id_cliente=id_cliente,
                nombre_completo=payload.contacto_nombre,
                parentesco=payload.contacto_parentesco,
                telefono=payload.contacto_telefono,
            )
        conn.commit()
        return TokenOut(
            access_token=create_access_token(id_usuario, "CLIENTE"),
            rol="CLIENTE",
            id_usuario=id_usuario,
        )
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.post("/login", response_model=TokenOut)
def login(payload: LoginIn, conn: Annotated[oracledb.Connection, Depends(get_db)]):
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT id_usuario, rol, password_hash, estado_cuenta
                FROM usuario
                WHERE correo = :correo
                """,
                correo=payload.correo.lower(),
            )
            usuario = row_as_dict(cursor)
        if usuario is None or not verify_password(payload.password, usuario["password_hash"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Correo o contraseña incorrectos.",
            )
        if usuario["estado_cuenta"] != "ACTIVA":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="La cuenta se encuentra bloqueada.",
            )
        with conn.cursor() as cursor:
            cursor.execute(
                "UPDATE usuario SET ultimo_acceso = SYSTIMESTAMP WHERE id_usuario = :id_usuario",
                id_usuario=usuario["id_usuario"],
            )
        conn.commit()
        return TokenOut(
            access_token=create_access_token(int(usuario["id_usuario"]), usuario["rol"]),
            rol=usuario["rol"],
            id_usuario=int(usuario["id_usuario"]),
        )
    except HTTPException:
        raise
    except oracledb.DatabaseError as exc:
        conn.rollback()
        raise handle_oracle_error(exc) from exc


@router.get("/me", response_model=PerfilOut)
def me(user: Annotated[dict[str, Any], Depends(get_current_user)]):
    return PerfilOut(**user)
