import re
import oracledb
from fastapi import HTTPException, status


def handle_oracle_error(exc: Exception) -> HTTPException:
    if isinstance(exc, oracledb.DatabaseError):
        error_obj = exc.args[0]
        code = getattr(error_obj, "code", 0)
        raw_message = getattr(error_obj, "message", str(exc))

        if 20001 <= code <= 20999:
            first_line = raw_message.splitlines()[0]
            clean_message = re.sub(r"^ORA-\d+:\s*", "", first_line).strip()
            return HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=clean_message,
            )

        if code == 1:
            return HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Ya existe un registro con esos datos únicos.",
            )

        if code in (2291, 2292):
            return HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Operación rechazada por integridad referencial en la base de datos.",
            )

    return HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Error interno al procesar la operación en la base de datos.",
    )

