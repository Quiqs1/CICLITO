from collections.abc import Generator
from datetime import date, datetime
from decimal import Decimal

import oracledb

from app.core.config import settings

pool: oracledb.ConnectionPool | None = None


def _init_session(conn: oracledb.Connection, requested_tag: str) -> None:
    with conn.cursor() as cursor:
        cursor.execute("ALTER SESSION SET TIME_ZONE = 'America/Mexico_City'")
        cursor.execute(
            f"ALTER SESSION SET CURRENT_SCHEMA = {settings.ORACLE_SCHEMA}")


def init_db_pool() -> None:
    global pool
    if pool is None:
        pool = oracledb.create_pool(
            user=settings.ORACLE_USER,
            password=settings.ORACLE_PASSWORD,
            dsn=settings.oracle_dsn,
            min=1,
            max=5,
            increment=1,
            session_callback=_init_session,
        )


def close_db_pool() -> None:
    global pool
    if pool is not None:
        pool.close()
        pool = None


def get_db() -> Generator[oracledb.Connection, None, None]:
    if pool is None:
        init_db_pool()
    assert pool is not None
    conn = pool.acquire()
    try:
        yield conn
    finally:
        pool.release(conn)


def serialize_value(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, datetime):
        return value.isoformat(sep=" ", timespec="seconds")
    if isinstance(value, date):
        return value.isoformat()
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="ignore")
    return value


def rows_as_dicts(cursor: oracledb.Cursor) -> list[dict]:
    if cursor.description is None:
        return []
    columns = [col[0].lower() for col in cursor.description]
    return [
        {col: serialize_value(val) for col, val in zip(columns, row)}
        for row in cursor.fetchall()
    ]


def row_as_dict(cursor: oracledb.Cursor) -> dict | None:
    if cursor.description is None:
        return None
    row = cursor.fetchone()
    if row is None:
        return None
    columns = [col[0].lower() for col in cursor.description]
    return {col: serialize_value(val) for col, val in zip(columns, row)}
