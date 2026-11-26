from datetime import date, datetime

from pydantic import BaseModel, EmailStr, Field


class RegistroIn(BaseModel):
    correo: EmailStr
    password: str = Field(min_length=8, max_length=72)
    id_pais: int
    tipo_identificacion: str = Field(pattern="^(INE|PASAPORTE|LICENCIA|OTRA)$")
    numero_identificacion: str = Field(min_length=4, max_length=30)
    nombres: str = Field(min_length=2, max_length=80)
    apellidos: str = Field(min_length=2, max_length=80)
    telefono: str = Field(min_length=7, max_length=20)
    fecha_nacimiento: date
    contacto_nombre: str = Field(min_length=3, max_length=120)
    contacto_parentesco: str = Field(min_length=2, max_length=30)
    contacto_telefono: str = Field(min_length=7, max_length=20)


class LoginIn(BaseModel):
    correo: EmailStr
    password: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    rol: str
    id_usuario: int


class PerfilOut(BaseModel):
    id_usuario: int
    rol: str
    correo: str
    estado_cuenta: str
    fecha_alta: datetime | str | None = None
    ultimo_acceso: datetime | str | None = None
    id_cliente: int | None = None
    cliente_nombres: str | None = None
    cliente_apellidos: str | None = None
    cliente_telefono: str | None = None
    fecha_nacimiento: date | str | None = None
    id_pais: int | None = None
    tipo_identificacion: str | None = None
    numero_identificacion: str | None = None
    id_empleado: int | None = None
    id_sucursal: int | None = None
    sucursal_nombre: str | None = None
    empleado_nombres: str | None = None
    empleado_apellidos: str | None = None
    puesto: str | None = None
    empleado_telefono: str | None = None
