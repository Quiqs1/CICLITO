from contextlib import asynccontextmanager
from typing import Annotated

import oracledb
from fastapi import Depends, FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.database import close_db_pool, get_db, init_db_pool, row_as_dict
from app.core.exceptions import handle_oracle_error
from app.routers import admin, auth, catalogo, operacion, reservas


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db_pool()
    yield
    close_db_pool()


app = FastAPI(
    title="CICLITO API",
    description="Portal de renta y flota de bicicletas — Cantera y Pedal, Oaxaca",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.FRONTEND_URL, "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(oracledb.DatabaseError)
async def oracle_exception_handler(_: Request, exc: oracledb.DatabaseError):
    http_exc = handle_oracle_error(exc)
    return JSONResponse(status_code=http_exc.status_code, content={"detail": http_exc.detail})


@app.get("/api/health")
def health(conn: Annotated[oracledb.Connection, Depends(get_db)]):
    with conn.cursor() as cursor:
        cursor.execute("SELECT COUNT(*) AS total FROM sucursal")
        row = row_as_dict(cursor)
    return {"status": "ok", "sucursales": int(row["total"]) if row else 0}


app.include_router(catalogo.router)
app.include_router(auth.router)
app.include_router(reservas.router)
app.include_router(operacion.router)
app.include_router(admin.router)
