from datetime import datetime
from pydantic import BaseModel, Field


class HorarioSucursalOut(BaseModel):
    dia_semana: int
    abierto: str
    hora_apertura: str | None
    hora_cierre: str | None


class SucursalOut(BaseModel):
    id_sucursal: int
    nombre: str
    direccion: str
    colonia_barrio: str
    telefono: str
    latitud: float
    longitud: float
    horarios: list[HorarioSucursalOut] = []


class TipoBicicletaOut(BaseModel):
    id_tipo: int
    nombre: str
    descripcion: str
    deposito_garantia: float
    edad_estatura_recomendada: str | None
    precio_hora: float | None
    precio_dia: float | None


class BicicletaDisponibleOut(BaseModel):
    id_bicicleta: int
    codigo_interno: str
    num_serie: str
    tipo_bicicleta: str
    marca: str
    modelo: str
    rodada: float
    talla_cuadro: str
    color: str
    id_sucursal: int
    sucursal_actual: str
    estado_actual: str
    precio_hora: float | None
    precio_dia: float | None
    deposito_garantia: float
    autonomia_km: float | None
    capacidad_bateria_wh: float | None
    foto_url: str | None = None


class CotizacionIn(BaseModel):
    id_tipo: int = Field(..., gt=0)
    fecha_inicio: datetime
    fecha_fin: datetime
    cantidad: int = Field(default=1, ge=1, le=5)


class CotizacionOut(BaseModel):
    id_tipo: int
    cantidad: int
    costo_unitario: float
    costo_total: float
    deposito_unitario: float
    deposito_total: float
    temporada_aplicada: str
    porcentaje_incremento: float
