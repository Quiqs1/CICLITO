"""Actualiza hashes bcrypt reales para las cuentas semilla (password: Ciclito2026#)."""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

import oracledb
from app.core.config import settings
from app.core.security import hash_password

PASSWORD = "Ciclito2026#"
CORREOS = [
    "admin@canteraypedal.mx",
    "lupita.ruiz@canteraypedal.mx",
    "carlos.mendez@canteraypedal.mx",
    "sofia.ramirez@canteraypedal.mx",
    "emma.schneider@mail.de",
    "diego.lopez@gmail.com",
    "valeria.santos@hotmail.com",
    "john.miller@outlook.com",
    "claire.dubois@orange.fr",
]


def main() -> None:
    hashed = hash_password(PASSWORD)
    conn = oracledb.connect(
        user=settings.ORACLE_USER,
        password=settings.ORACLE_PASSWORD,
        dsn=settings.oracle_dsn,
    )
    try:
        with conn.cursor() as cursor:
            cursor.execute(f"ALTER SESSION SET CURRENT_SCHEMA = {settings.ORACLE_SCHEMA}")
            for correo in CORREOS:
                cursor.execute(
                    "UPDATE usuario SET password_hash = :h WHERE correo = :c",
                    h=hashed,
                    c=correo,
                )
        conn.commit()
        print(f"Actualizadas {len(CORREOS)} cuentas. Password demo: {PASSWORD}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
