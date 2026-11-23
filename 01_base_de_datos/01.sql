CREATE TABLE usuario (
    id_usuario     NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    rol            VARCHAR2(15)  NOT NULL,
    correo         VARCHAR2(120) NOT NULL,
    password_hash  VARCHAR2(100) NOT NULL,
    estado_cuenta  VARCHAR2(10)  DEFAULT 'ACTIVA' NOT NULL,
    fecha_alta     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    ultimo_acceso  TIMESTAMP,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT chk_usuario_rol CHECK (rol IN ('CLIENTE', 'EMPLEADO', 'ADMINISTRADOR')),
    CONSTRAINT chk_usuario_correo_min CHECK (correo = LOWER(correo)),
    CONSTRAINT chk_usuario_estado CHECK (estado_cuenta IN ('ACTIVA', 'BLOQUEADA'))
);

CREATE TABLE token_recuperacion (
    id_token          NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    id_usuario        NUMBER(10)    NOT NULL,
    token             VARCHAR2(100) NOT NULL,
    fecha_creacion    TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_expiracion  TIMESTAMP     NOT NULL,
    usado             CHAR(1)       DEFAULT 'N' NOT NULL,
    CONSTRAINT pk_token_recuperacion PRIMARY KEY (id_token),
    CONSTRAINT uq_token_valor UNIQUE (token),
    CONSTRAINT fk_token_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_token_expiracion CHECK (fecha_expiracion > fecha_creacion),
    CONSTRAINT chk_token_usado CHECK (usado IN ('S', 'N'))
);

CREATE INDEX ix_token_usuario ON token_recuperacion (id_usuario);

CREATE TABLE pais (
    id_pais     NUMBER(5)    GENERATED ALWAYS AS IDENTITY,
    nombre      VARCHAR2(80) NOT NULL,
    codigo_iso  CHAR(3)      NOT NULL,
    CONSTRAINT pk_pais PRIMARY KEY (id_pais),
    CONSTRAINT uq_pais_nombre UNIQUE (nombre),
    CONSTRAINT uq_pais_iso UNIQUE (codigo_iso),
    CONSTRAINT chk_pais_iso_mayus CHECK (codigo_iso = UPPER(codigo_iso))
);

CREATE TABLE cliente (
    id_cliente             NUMBER(10)   GENERATED ALWAYS AS IDENTITY,
    id_usuario             NUMBER(10)   NOT NULL,
    id_pais                NUMBER(5)    NOT NULL,
    tipo_identificacion    VARCHAR2(15) NOT NULL,
    numero_identificacion  VARCHAR2(30) NOT NULL,
    nombres                VARCHAR2(80) NOT NULL,
    apellidos              VARCHAR2(80) NOT NULL,
    telefono               VARCHAR2(20) NOT NULL,
    fecha_nacimiento       DATE         NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_usuario UNIQUE (id_usuario),
    CONSTRAINT uq_cliente_identificacion UNIQUE (tipo_identificacion, numero_identificacion),
    CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_cliente_pais FOREIGN KEY (id_pais) REFERENCES pais (id_pais),
    CONSTRAINT chk_cliente_tipo_id CHECK (tipo_identificacion IN ('INE', 'PASAPORTE', 'LICENCIA', 'OTRA'))
);

CREATE INDEX ix_cliente_pais ON cliente (id_pais);
CREATE INDEX ix_cliente_apellidos ON cliente (apellidos, nombres);

CREATE TABLE contacto_emergencia (
    id_contacto      NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    id_cliente       NUMBER(10)    NOT NULL,
    nombre_completo  VARCHAR2(120) NOT NULL,
    parentesco       VARCHAR2(30)  NOT NULL,
    telefono         VARCHAR2(20)  NOT NULL,
    CONSTRAINT pk_contacto_emergencia PRIMARY KEY (id_contacto),
    CONSTRAINT uq_contacto_cliente UNIQUE (id_cliente),
    CONSTRAINT fk_contacto_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente) ON DELETE CASCADE
);

CREATE TABLE sucursal (
    id_sucursal     NUMBER(5)     GENERATED ALWAYS AS IDENTITY,
    nombre          VARCHAR2(60)  NOT NULL,
    direccion       VARCHAR2(150) NOT NULL,
    colonia_barrio  VARCHAR2(80)  NOT NULL,
    telefono        VARCHAR2(20)  NOT NULL,
    latitud         NUMBER(9,6)   NOT NULL,
    longitud        NUMBER(9,6)   NOT NULL,
    CONSTRAINT pk_sucursal PRIMARY KEY (id_sucursal),
    CONSTRAINT uq_sucursal_nombre UNIQUE (nombre),
    CONSTRAINT chk_sucursal_lat CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT chk_sucursal_lon CHECK (longitud BETWEEN -180 AND 180)
);

CREATE TABLE horario_sucursal (
    id_sucursal    NUMBER(5)   NOT NULL,
    dia_semana     NUMBER(1)   NOT NULL,
    abierto        CHAR(1)     DEFAULT 'S' NOT NULL,
    hora_apertura  VARCHAR2(5),
    hora_cierre    VARCHAR2(5),
    CONSTRAINT pk_horario_sucursal PRIMARY KEY (id_sucursal, dia_semana),
    CONSTRAINT fk_horario_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursal (id_sucursal) ON DELETE CASCADE,
    CONSTRAINT chk_horario_dia CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT chk_horario_abierto CHECK (abierto IN ('S', 'N')),
    CONSTRAINT chk_horario_horas CHECK (
        (abierto = 'N' AND hora_apertura IS NULL AND hora_cierre IS NULL) OR
        (abierto = 'S' AND hora_apertura IS NOT NULL AND hora_cierre IS NOT NULL AND hora_cierre > hora_apertura)
    )
);

CREATE TABLE empleado (
    id_empleado  NUMBER(10)   GENERATED ALWAYS AS IDENTITY,
    id_usuario   NUMBER(10)   NOT NULL,
    id_sucursal  NUMBER(5)    NOT NULL,
    nombres      VARCHAR2(80) NOT NULL,
    apellidos    VARCHAR2(80) NOT NULL,
    telefono     VARCHAR2(20) NOT NULL,
    puesto       VARCHAR2(40) NOT NULL,
    CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_empleado_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_empleado_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursal (id_sucursal)
);

CREATE INDEX ix_empleado_sucursal ON empleado (id_sucursal);

CREATE TABLE tipo_bicicleta (
    id_tipo                    NUMBER(5)     GENERATED ALWAYS AS IDENTITY,
    nombre                     VARCHAR2(30)  NOT NULL,
    descripcion                VARCHAR2(200) NOT NULL,
    deposito_garantia          NUMBER(8,2)   NOT NULL,
    edad_estatura_recomendada  VARCHAR2(80),
    CONSTRAINT pk_tipo_bicicleta PRIMARY KEY (id_tipo),
    CONSTRAINT uq_tipo_bici_nombre UNIQUE (nombre),
    CONSTRAINT chk_tipo_bici_deposito CHECK (deposito_garantia >= 0)
);

CREATE TABLE estado_bicicleta (
    id_estado_bici   NUMBER(5)     GENERATED ALWAYS AS IDENTITY,
    nombre           VARCHAR2(30)  NOT NULL,
    permite_reserva  CHAR(1)       DEFAULT 'N' NOT NULL,
    descripcion      VARCHAR2(100),
    CONSTRAINT pk_estado_bicicleta PRIMARY KEY (id_estado_bici),
    CONSTRAINT uq_estado_bici_nombre UNIQUE (nombre),
    CONSTRAINT chk_estado_bici_reserva CHECK (permite_reserva IN ('S', 'N'))
);

CREATE TABLE bicicleta (
    id_bicicleta        NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    codigo_interno      VARCHAR2(10)  NOT NULL,
    num_serie           VARCHAR2(40)  NOT NULL,
    id_tipo             NUMBER(5)     NOT NULL,
    id_estado_actual    NUMBER(5)     NOT NULL,
    id_sucursal_actual  NUMBER(5)     NOT NULL,
    marca               VARCHAR2(40)  NOT NULL,
    modelo              VARCHAR2(40)  NOT NULL,
    rodada              NUMBER(4,1)   NOT NULL,
    talla_cuadro        VARCHAR2(10)  NOT NULL,
    color               VARCHAR2(30)  NOT NULL,
    anio                NUMBER(4)     NOT NULL,
    fecha_adquisicion   DATE          NOT NULL,
    costo_adquisicion   NUMBER(10,2)  NOT NULL,
    foto_url            VARCHAR2(300),
    CONSTRAINT pk_bicicleta PRIMARY KEY (id_bicicleta),
    CONSTRAINT uq_bici_codigo UNIQUE (codigo_interno),
    CONSTRAINT uq_bici_serie UNIQUE (num_serie),
    CONSTRAINT fk_bici_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_bicicleta (id_tipo),
    CONSTRAINT fk_bici_estado FOREIGN KEY (id_estado_actual) REFERENCES estado_bicicleta (id_estado_bici),
    CONSTRAINT fk_bici_sucursal FOREIGN KEY (id_sucursal_actual) REFERENCES sucursal (id_sucursal),
    CONSTRAINT chk_bici_rodada CHECK (rodada > 0),
    CONSTRAINT chk_bici_anio CHECK (anio >= 1990),
    CONSTRAINT chk_bici_costo CHECK (costo_adquisicion >= 0)
);

CREATE INDEX ix_bici_tipo ON bicicleta (id_tipo);
CREATE INDEX ix_bici_estado ON bicicleta (id_estado_actual);
CREATE INDEX ix_bici_sucursal ON bicicleta (id_sucursal_actual);

CREATE TABLE bicicleta_electrica (
    id_bicicleta          NUMBER(10)  NOT NULL,
    autonomia_km          NUMBER(5,1) NOT NULL,
    capacidad_bateria_wh  NUMBER(6,1) NOT NULL,
    CONSTRAINT pk_bicicleta_electrica PRIMARY KEY (id_bicicleta),
    CONSTRAINT fk_bici_elec_bici FOREIGN KEY (id_bicicleta) REFERENCES bicicleta (id_bicicleta) ON DELETE CASCADE,
    CONSTRAINT chk_bici_elec_autonomia CHECK (autonomia_km > 0),
    CONSTRAINT chk_bici_elec_bateria CHECK (capacidad_bateria_wh > 0)
);

CREATE TABLE historial_estado_bici (
    id_historial        NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    id_bicicleta        NUMBER(10)    NOT NULL,
    id_estado_anterior  NUMBER(5),
    id_estado_nuevo     NUMBER(5)     NOT NULL,
    id_usuario          NUMBER(10),
    fecha_hora          TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    motivo              VARCHAR2(200) DEFAULT 'Cambio de estado' NOT NULL,
    CONSTRAINT pk_historial_estado_bici PRIMARY KEY (id_historial),
    CONSTRAINT fk_hist_bici FOREIGN KEY (id_bicicleta) REFERENCES bicicleta (id_bicicleta),
    CONSTRAINT fk_hist_estado_ant FOREIGN KEY (id_estado_anterior) REFERENCES estado_bicicleta (id_estado_bici),
    CONSTRAINT fk_hist_estado_nvo FOREIGN KEY (id_estado_nuevo) REFERENCES estado_bicicleta (id_estado_bici),
    CONSTRAINT fk_hist_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

CREATE INDEX ix_hist_bici ON historial_estado_bici (id_bicicleta);
CREATE INDEX ix_hist_estado_ant ON historial_estado_bici (id_estado_anterior);
CREATE INDEX ix_hist_estado_nvo ON historial_estado_bici (id_estado_nuevo);
CREATE INDEX ix_hist_usuario ON historial_estado_bici (id_usuario);
CREATE INDEX ix_hist_fecha ON historial_estado_bici (fecha_hora);

CREATE TABLE tarifa (
    id_tarifa      NUMBER(10)  GENERATED ALWAYS AS IDENTITY,
    id_tipo        NUMBER(5)   NOT NULL,
    precio_hora    NUMBER(8,2) NOT NULL,
    precio_dia     NUMBER(8,2) NOT NULL,
    vigente_desde  DATE        NOT NULL,
    vigente_hasta  DATE,
    CONSTRAINT pk_tarifa PRIMARY KEY (id_tarifa),
    CONSTRAINT fk_tarifa_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_bicicleta (id_tipo),
    CONSTRAINT chk_tarifa_precios CHECK (precio_hora > 0 AND precio_dia > precio_hora),
    CONSTRAINT chk_tarifa_vigencia CHECK (vigente_hasta IS NULL OR vigente_hasta > vigente_desde)
);

CREATE INDEX ix_tarifa_tipo ON tarifa (id_tipo);

CREATE TABLE temporada (
    id_temporada           NUMBER(5)    GENERATED ALWAYS AS IDENTITY,
    nombre                 VARCHAR2(60) NOT NULL,
    fecha_inicio           DATE         NOT NULL,
    fecha_fin              DATE         NOT NULL,
    porcentaje_incremento  NUMBER(5,2)  NOT NULL,
    CONSTRAINT pk_temporada PRIMARY KEY (id_temporada),
    CONSTRAINT chk_temporada_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_temporada_pct CHECK (porcentaje_incremento BETWEEN 0 AND 100)
);

CREATE INDEX ix_temporada_fechas ON temporada (fecha_inicio, fecha_fin);

CREATE TABLE estado_reserva (
    id_estado_res       NUMBER(5)    GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR2(30) NOT NULL,
    bloquea_inventario  CHAR(1)      DEFAULT 'N' NOT NULL,
    CONSTRAINT pk_estado_reserva PRIMARY KEY (id_estado_res),
    CONSTRAINT uq_estado_res_nombre UNIQUE (nombre),
    CONSTRAINT chk_estado_res_bloqueo CHECK (bloquea_inventario IN ('S', 'N'))
);

CREATE TABLE reserva (
    id_reserva                NUMBER(10)   GENERATED ALWAYS AS IDENTITY,
    folio                     VARCHAR2(15) NOT NULL,
    id_cliente                NUMBER(10)   NOT NULL,
    id_sucursal_recogida      NUMBER(5)    NOT NULL,
    id_sucursal_devolucion    NUMBER(5)    NOT NULL,
    id_estado_res             NUMBER(5)    NOT NULL,
    id_temporada              NUMBER(5),
    id_empleado_entrega       NUMBER(10),
    id_empleado_devolucion    NUMBER(10),
    fecha_creacion            DATE         DEFAULT SYSDATE NOT NULL,
    fecha_inicio_prog         DATE         NOT NULL,
    fecha_fin_prog            DATE         NOT NULL,
    fecha_recogida_real       DATE,
    fecha_devolucion_real     DATE,
    fecha_cancelacion         DATE,
    porcentaje_temp_aplicado  NUMBER(5,2)  DEFAULT 0 NOT NULL,
    total_estimado            NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
    CONSTRAINT uq_reserva_folio UNIQUE (folio),
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_reserva_suc_rec FOREIGN KEY (id_sucursal_recogida) REFERENCES sucursal (id_sucursal),
    CONSTRAINT fk_reserva_suc_dev FOREIGN KEY (id_sucursal_devolucion) REFERENCES sucursal (id_sucursal),
    CONSTRAINT fk_reserva_estado FOREIGN KEY (id_estado_res) REFERENCES estado_reserva (id_estado_res),
    CONSTRAINT fk_reserva_temporada FOREIGN KEY (id_temporada) REFERENCES temporada (id_temporada),
    CONSTRAINT fk_reserva_emp_ent FOREIGN KEY (id_empleado_entrega) REFERENCES empleado (id_empleado),
    CONSTRAINT fk_reserva_emp_dev FOREIGN KEY (id_empleado_devolucion) REFERENCES empleado (id_empleado),
    CONSTRAINT chk_reserva_fechas CHECK (fecha_fin_prog > fecha_inicio_prog),
    CONSTRAINT chk_reserva_pct_temp CHECK (porcentaje_temp_aplicado BETWEEN 0 AND 100),
    CONSTRAINT chk_reserva_total CHECK (total_estimado >= 0)
);

CREATE INDEX ix_reserva_cliente ON reserva (id_cliente);
CREATE INDEX ix_reserva_suc_rec ON reserva (id_sucursal_recogida);
CREATE INDEX ix_reserva_suc_dev ON reserva (id_sucursal_devolucion);
CREATE INDEX ix_reserva_estado ON reserva (id_estado_res);
CREATE INDEX ix_reserva_temporada ON reserva (id_temporada);
CREATE INDEX ix_reserva_emp_ent ON reserva (id_empleado_entrega);
CREATE INDEX ix_reserva_emp_dev ON reserva (id_empleado_devolucion);
CREATE INDEX ix_reserva_fechas_prog ON reserva (fecha_inicio_prog, fecha_fin_prog);

CREATE TABLE detalle_reserva (
    id_detalle_res        NUMBER(10)   GENERATED ALWAYS AS IDENTITY,
    id_reserva            NUMBER(10)   NOT NULL,
    id_bicicleta          NUMBER(10)   NOT NULL,
    precio_hora_aplicado  NUMBER(8,2)  NOT NULL,
    precio_dia_aplicado   NUMBER(8,2)  NOT NULL,
    deposito_aplicado     NUMBER(8,2)  NOT NULL,
    dias_cobrados         NUMBER(3)    DEFAULT 0 NOT NULL,
    horas_cobradas        NUMBER(3)    DEFAULT 0 NOT NULL,
    subtotal              NUMBER(10,2) NOT NULL,
    recargo_retraso       NUMBER(10,2) DEFAULT 0 NOT NULL,
    cargo_dano            NUMBER(10,2) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_detalle_reserva PRIMARY KEY (id_detalle_res),
    CONSTRAINT uq_detalle_reserva_bici UNIQUE (id_reserva, id_bicicleta),
    CONSTRAINT fk_det_res_reserva FOREIGN KEY (id_reserva) REFERENCES reserva (id_reserva) ON DELETE CASCADE,
    CONSTRAINT fk_det_res_bici FOREIGN KEY (id_bicicleta) REFERENCES bicicleta (id_bicicleta),
    CONSTRAINT chk_det_res_precios CHECK (precio_hora_aplicado > 0 AND precio_dia_aplicado > 0 AND deposito_aplicado >= 0),
    CONSTRAINT chk_det_res_tiempo CHECK (dias_cobrados >= 0 AND horas_cobradas >= 0 AND (dias_cobrados + horas_cobradas) > 0),
    CONSTRAINT chk_det_res_montos CHECK (subtotal >= 0 AND recargo_retraso >= 0 AND cargo_dano >= 0)
);

CREATE INDEX ix_det_res_reserva ON detalle_reserva (id_reserva);
CREATE INDEX ix_det_res_bici ON detalle_reserva (id_bicicleta);

CREATE TABLE pago (
    id_pago        NUMBER(10)   GENERATED ALWAYS AS IDENTITY,
    id_reserva     NUMBER(10)   NOT NULL,
    id_empleado    NUMBER(10),
    metodo_pago    VARCHAR2(15) NOT NULL,
    concepto_pago  VARCHAR2(25) NOT NULL,
    monto          NUMBER(10,2) NOT NULL,
    fecha_hora     TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    referencia     VARCHAR2(30),
    CONSTRAINT pk_pago PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva) REFERENCES reserva (id_reserva),
    CONSTRAINT fk_pago_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
    CONSTRAINT chk_pago_metodo CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA')),
    CONSTRAINT chk_pago_concepto CHECK (concepto_pago IN ('ANTICIPO', 'SALDO_RENTA', 'DEPOSITO', 'DEVOLUCION_DEPOSITO', 'RECARGO_RETRASO', 'CARGO_DANO', 'REEMBOLSO_ANTICIPO')),
    CONSTRAINT chk_pago_monto CHECK (monto > 0)
);

CREATE INDEX ix_pago_reserva ON pago (id_reserva);
CREATE INDEX ix_pago_empleado ON pago (id_empleado);
CREATE INDEX ix_pago_fecha ON pago (fecha_hora);

CREATE TABLE punto_inspeccion (
    id_punto     NUMBER(5)     GENERATED ALWAYS AS IDENTITY,
    nombre       VARCHAR2(60)  NOT NULL,
    descripcion  VARCHAR2(200) NOT NULL,
    CONSTRAINT pk_punto_inspeccion PRIMARY KEY (id_punto),
    CONSTRAINT uq_punto_insp_nombre UNIQUE (nombre)
);

CREATE TABLE punto_inspeccion_tipo (
    id_punto  NUMBER(5) NOT NULL,
    id_tipo   NUMBER(5) NOT NULL,
    CONSTRAINT pk_punto_inspeccion_tipo PRIMARY KEY (id_punto, id_tipo),
    CONSTRAINT fk_pit_punto FOREIGN KEY (id_punto) REFERENCES punto_inspeccion (id_punto),
    CONSTRAINT fk_pit_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_bicicleta (id_tipo)
);

CREATE INDEX ix_pit_tipo ON punto_inspeccion_tipo (id_tipo);

CREATE TABLE revision (
    id_revision       NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    id_bicicleta      NUMBER(10)    NOT NULL,
    id_empleado       NUMBER(10)    NOT NULL,
    id_reserva        NUMBER(10),
    tipo_revision     VARCHAR2(12)  NOT NULL,
    fecha_hora        DATE          DEFAULT SYSDATE NOT NULL,
    resultado_global  VARCHAR2(15)  DEFAULT 'CORRECTO' NOT NULL,
    observaciones     VARCHAR2(500),
    CONSTRAINT pk_revision PRIMARY KEY (id_revision),
    CONSTRAINT fk_rev_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES bicicleta (id_bicicleta),
    CONSTRAINT fk_rev_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
    CONSTRAINT fk_rev_reserva FOREIGN KEY (id_reserva) REFERENCES reserva (id_reserva),
    CONSTRAINT chk_rev_tipo CHECK (tipo_revision IN ('ENTREGA', 'DEVOLUCION', 'PERIODICA')),
    CONSTRAINT chk_rev_resultado CHECK (resultado_global IN ('CORRECTO', 'REQUIERE_AJUSTE', 'FALLA'))
);

CREATE INDEX ix_rev_bicicleta ON revision (id_bicicleta);
CREATE INDEX ix_rev_empleado ON revision (id_empleado);
CREATE INDEX ix_rev_reserva ON revision (id_reserva);
CREATE INDEX ix_rev_fecha ON revision (fecha_hora);

CREATE TABLE detalle_revision (
    id_detalle_rev  NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    id_revision     NUMBER(10)    NOT NULL,
    id_punto        NUMBER(5)     NOT NULL,
    resultado       VARCHAR2(15)  NOT NULL,
    comentario      VARCHAR2(300),
    CONSTRAINT pk_detalle_revision PRIMARY KEY (id_detalle_rev),
    CONSTRAINT uq_detalle_revision_punto UNIQUE (id_revision, id_punto),
    CONSTRAINT fk_det_rev_revision FOREIGN KEY (id_revision) REFERENCES revision (id_revision) ON DELETE CASCADE,
    CONSTRAINT fk_det_rev_punto FOREIGN KEY (id_punto) REFERENCES punto_inspeccion (id_punto),
    CONSTRAINT chk_det_rev_resultado CHECK (resultado IN ('CORRECTO', 'REQUIERE_AJUSTE', 'FALLA'))
);

CREATE INDEX ix_det_rev_revision ON detalle_revision (id_revision);
CREATE INDEX ix_det_rev_punto ON detalle_revision (id_punto);

CREATE TABLE orden_mantenimiento (
    id_orden             NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    id_bicicleta         NUMBER(10)    NOT NULL,
    id_empleado          NUMBER(10)    NOT NULL,
    id_revision_origen   NUMBER(10),
    diagnostico          VARCHAR2(500) NOT NULL,
    descripcion_trabajo  VARCHAR2(500),
    costo_mano_obra      NUMBER(10,2)  DEFAULT 0 NOT NULL,
    fecha_inicio         DATE          DEFAULT SYSDATE NOT NULL,
    fecha_fin            DATE,
    estado_orden         VARCHAR2(15)  DEFAULT 'ABIERTA' NOT NULL,
    CONSTRAINT pk_orden_mantenimiento PRIMARY KEY (id_orden),
    CONSTRAINT fk_orden_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES bicicleta (id_bicicleta),
    CONSTRAINT fk_orden_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
    CONSTRAINT fk_orden_revision FOREIGN KEY (id_revision_origen) REFERENCES revision (id_revision),
    CONSTRAINT chk_orden_costo_mo CHECK (costo_mano_obra >= 0),
    CONSTRAINT chk_orden_estado CHECK (estado_orden IN ('ABIERTA', 'EN_PROCESO', 'CERRADA')),
    CONSTRAINT chk_orden_cierre CHECK (estado_orden <> 'CERRADA' OR fecha_fin IS NOT NULL)
);

CREATE INDEX ix_orden_bicicleta ON orden_mantenimiento (id_bicicleta);
CREATE INDEX ix_orden_empleado ON orden_mantenimiento (id_empleado);
CREATE INDEX ix_orden_revision ON orden_mantenimiento (id_revision_origen);
CREATE INDEX ix_orden_estado ON orden_mantenimiento (estado_orden);

CREATE TABLE detalle_mantenimiento (
    id_detalle_mant  NUMBER(10)   GENERATED ALWAYS AS IDENTITY,
    id_orden         NUMBER(10)   NOT NULL,
    nombre_refaccion VARCHAR2(80) NOT NULL,
    cantidad         NUMBER(4)    NOT NULL,
    costo_unitario   NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_detalle_mantenimiento PRIMARY KEY (id_detalle_mant),
    CONSTRAINT fk_det_mant_orden FOREIGN KEY (id_orden) REFERENCES orden_mantenimiento (id_orden) ON DELETE CASCADE,
    CONSTRAINT chk_det_mant_cant CHECK (cantidad > 0),
    CONSTRAINT chk_det_mant_costo CHECK (costo_unitario >= 0)
);

CREATE INDEX ix_det_mant_orden ON detalle_mantenimiento (id_orden);