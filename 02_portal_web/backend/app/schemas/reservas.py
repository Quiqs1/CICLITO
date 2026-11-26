from datetime import datetime

from pydantic import BaseModel, Field


class ReservaCreateIn(BaseModel):
    id_sucursal_recogida: int
    id_sucursal_devolucion: int
    fecha_inicio: datetime
    fecha_fin: datetime
    ids_bicicletas: list[int] = Field(min_length=1, max_length=5)


class ReservaCreadaOut(BaseModel):
    id_reserva: int
    folio: str


class PagoIn(BaseModel):
    metodo_pago: str = Field(pattern="^(EFECTIVO|TARJETA|TRANSFERENCIA)$")
    concepto_pago: str = Field(pattern="^(ANTICIPO|SALDO_RENTA|DEPOSITO)$")
    monto: float = Field(gt=0)
    referencia: str | None = Field(default=None, max_length=30)


class DetalleReservaOut(BaseModel):
    id_detalle_res: int
    id_bicicleta: int
    codigo_interno: str | None = None
    precio_hora_aplicado: float
    precio_dia_aplicado: float
    deposito_aplicado: float
    dias_cobrados: int
    horas_cobradas: int
    subtotal: float
    recargo_retraso: float
    cargo_dano: float
