from pydantic import BaseModel, Field


class PuntoRevisionIn(BaseModel):
    id_punto: int
    resultado: str = Field(pattern="^(CORRECTO|REQUIERE_AJUSTE|FALLA)$")
    comentario: str | None = Field(default=None, max_length=300)


class ChecklistBiciIn(BaseModel):
    id_bicicleta: int
    observaciones: str | None = Field(default=None, max_length=500)
    cargo_dano: float = Field(default=0, ge=0)
    puntos: list[PuntoRevisionIn] = Field(min_length=1)


class EntregaIn(BaseModel):
    checklists: list[ChecklistBiciIn] = Field(min_length=1)


class DevolucionIn(BaseModel):
    checklists: list[ChecklistBiciIn] = Field(min_length=1)


class OrdenMantIn(BaseModel):
    id_bicicleta: int
    diagnostico: str = Field(min_length=5, max_length=500)
    descripcion_trabajo: str | None = Field(default=None, max_length=500)
    costo_mano_obra: float = Field(default=0, ge=0)
    id_revision_origen: int | None = None


class OrdenMantPatchIn(BaseModel):
    estado_orden: str | None = Field(default=None, pattern="^(ABIERTA|EN_PROCESO|CERRADA)$")
    descripcion_trabajo: str | None = Field(default=None, max_length=500)
    costo_mano_obra: float | None = Field(default=None, ge=0)


class RefaccionIn(BaseModel):
    nombre_refaccion: str = Field(min_length=2, max_length=80)
    cantidad: int = Field(gt=0)
    costo_unitario: float = Field(ge=0)
