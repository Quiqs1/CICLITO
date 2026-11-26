from datetime import date

from pydantic import BaseModel, Field


class BicicletaIn(BaseModel):
    codigo_interno: str = Field(min_length=3, max_length=10)
    num_serie: str = Field(min_length=3, max_length=40)
    id_tipo: int
    id_estado_actual: int
    id_sucursal_actual: int
    marca: str
    modelo: str
    rodada: float = Field(gt=0)
    talla_cuadro: str
    color: str
    anio: int = Field(ge=1990)
    fecha_adquisicion: date
    costo_adquisicion: float = Field(ge=0)
    foto_url: str | None = None
    autonomia_km: float | None = Field(default=None, gt=0)
    capacidad_bateria_wh: float | None = Field(default=None, gt=0)


class TarifaIn(BaseModel):
    id_tipo: int
    precio_hora: float = Field(gt=0)
    precio_dia: float = Field(gt=0)
    vigente_desde: date
    vigente_hasta: date | None = None


class TemporadaIn(BaseModel):
    nombre: str = Field(min_length=3, max_length=60)
    fecha_inicio: date
    fecha_fin: date
    porcentaje_incremento: float = Field(ge=0, le=100)


class UsuarioEstadoIn(BaseModel):
    estado_cuenta: str = Field(pattern="^(ACTIVA|BLOQUEADA)$")
