from datetime import datetime, timedelta, timezone
from typing import Annotated, Any

import bcrypt
import jwt
import oracledb
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import settings
from app.core.database import get_db, row_as_dict

bearer_scheme = HTTPBearer(auto_error=True)


def hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))
    except ValueError:
        return False


def create_access_token(id_usuario: int, rol: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.JWT_EXPIRE_MINUTES)
    payload = {"sub": str(id_usuario), "rol": rol, "exp": expire}
    return jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def decode_token(token: str) -> dict[str, Any]:
    try:
        return jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
    except jwt.ExpiredSignatureError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="El token de sesión ha expirado.",
        ) from exc
    except jwt.InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de sesión inválido.",
        ) from exc


def load_usuario(conn: oracledb.Connection, id_usuario: int) -> dict[str, Any] | None:
    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                u.id_usuario, u.rol, u.correo, u.estado_cuenta, u.fecha_alta, u.ultimo_acceso,
                c.id_cliente, c.nombres AS cliente_nombres, c.apellidos AS cliente_apellidos,
                c.telefono AS cliente_telefono, c.fecha_nacimiento, c.id_pais,
                c.tipo_identificacion, c.numero_identificacion,
                e.id_empleado, e.id_sucursal, e.nombres AS empleado_nombres,
                e.apellidos AS empleado_apellidos, e.puesto, e.telefono AS empleado_telefono,
                s.nombre AS sucursal_nombre
            FROM usuario u
            LEFT JOIN cliente c ON c.id_usuario = u.id_usuario
            LEFT JOIN empleado e ON e.id_usuario = u.id_usuario
            LEFT JOIN sucursal s ON s.id_sucursal = e.id_sucursal
            WHERE u.id_usuario = :id_usuario
            """,
            {"id_usuario": id_usuario},
        )
        return row_as_dict(cursor)


def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(bearer_scheme)],
    conn: Annotated[oracledb.Connection, Depends(get_db)],
) -> dict[str, Any]:
    payload = decode_token(credentials.credentials)
    try:
        id_usuario = int(payload.get("sub", 0))
    except (TypeError, ValueError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de sesión inválido.",
        ) from exc

    usuario = load_usuario(conn, id_usuario)
    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado.",
        )
    if usuario["estado_cuenta"] != "ACTIVA":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="La cuenta se encuentra bloqueada.",
        )
    return usuario


def require_roles(*roles: str):
    def dependency(user: Annotated[dict[str, Any], Depends(get_current_user)]) -> dict[str, Any]:
        if user["rol"] not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No tiene permisos para esta operación.",
            )
        return user

    return dependency
