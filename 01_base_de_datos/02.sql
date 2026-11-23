INSERT INTO pais (nombre, codigo_iso) VALUES ('Mexico', 'MEX');
INSERT INTO pais (nombre, codigo_iso) VALUES ('Alemania', 'DEU');
INSERT INTO pais (nombre, codigo_iso) VALUES ('Estados Unidos', 'USA');
INSERT INTO pais (nombre, codigo_iso) VALUES ('Canada', 'CAN');
INSERT INTO pais (nombre, codigo_iso) VALUES ('Espana', 'ESP');
INSERT INTO pais (nombre, codigo_iso) VALUES ('Francia', 'FRA');

INSERT INTO sucursal (nombre, direccion, colonia_barrio, telefono, latitud, longitud)
VALUES ('Centro Historico', 'Andador Macedonio Alcala 402', 'Centro', '9510000001', 17.064210, -96.724850);
INSERT INTO sucursal (nombre, direccion, colonia_barrio, telefono, latitud, longitud)
VALUES ('El Llano', 'Av. Benito Juarez 703', 'Ruta Independencia', '9510000002', 17.068940, -96.721120);
INSERT INTO sucursal (nombre, direccion, colonia_barrio, telefono, latitud, longitud)
VALUES ('Jalatlaco', 'Calle Aldama 210', 'Barrio de Jalatlaco', '9510000003', 17.066320, -96.716480);

INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (1, 1, 'S', '08:00', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (1, 2, 'S', '08:00', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (1, 3, 'S', '08:00', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (1, 4, 'S', '08:00', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (1, 5, 'S', '08:00', '21:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (1, 6, 'S', '08:00', '21:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (1, 7, 'S', '09:00', '19:00');

INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (2, 1, 'S', '08:30', '19:30');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (2, 2, 'S', '08:30', '19:30');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (2, 3, 'S', '08:30', '19:30');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (2, 4, 'S', '08:30', '19:30');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (2, 5, 'S', '08:30', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (2, 6, 'S', '08:30', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (2, 7, 'S', '09:00', '18:00');

INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (3, 1, 'N', NULL, NULL);
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (3, 2, 'S', '09:00', '19:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (3, 3, 'S', '09:00', '19:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (3, 4, 'S', '09:00', '19:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (3, 5, 'S', '09:00', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (3, 6, 'S', '09:00', '20:00');
INSERT INTO horario_sucursal (id_sucursal, dia_semana, abierto, hora_apertura, hora_cierre) VALUES (3, 7, 'S', '09:00', '18:00');

INSERT INTO tipo_bicicleta (nombre, descripcion, deposito_garantia, edad_estatura_recomendada)
VALUES ('Urbana', 'Bicicleta comoda de paseo con canasta y salpicaderas para recorridos en ciudad', 500.00, 'Desde 1.55 m');
INSERT INTO tipo_bicicleta (nombre, descripcion, deposito_garantia, edad_estatura_recomendada)
VALUES ('Montana', 'Bicicleta con suspension delantera y llantas anchas para terraceria y senderos', 1000.00, 'Desde 1.60 m');
INSERT INTO tipo_bicicleta (nombre, descripcion, deposito_garantia, edad_estatura_recomendada)
VALUES ('Ruta', 'Bicicleta ligera de cuadro aerodinamico para trayectos largos en pavimento', 1500.00, 'Desde 1.65 m');
INSERT INTO tipo_bicicleta (nombre, descripcion, deposito_garantia, edad_estatura_recomendada)
VALUES ('Electrica', 'Bicicleta con asistencia electrica al pedaleo y bateria recargable', 3000.00, 'Mayores de 18 anos, desde 1.58 m');
INSERT INTO tipo_bicicleta (nombre, descripcion, deposito_garantia, edad_estatura_recomendada)
VALUES ('Tandem', 'Bicicleta doble para dos ciclistas en tandem', 1200.00, 'Dos ciclistas desde 1.50 m');
INSERT INTO tipo_bicicleta (nombre, descripcion, deposito_garantia, edad_estatura_recomendada)
VALUES ('Infantil', 'Bicicleta rodada 20 para ninos y adolescentes', 400.00, 'De 7 a 12 anos (1.20 a 1.48 m)');

INSERT INTO estado_bicicleta (nombre, permite_reserva, descripcion)
VALUES ('Disponible', 'S', 'Lista en sucursal para renta o reservacion');
INSERT INTO estado_bicicleta (nombre, permite_reserva, descripcion)
VALUES ('Reservada', 'S', 'Apartada para una reserva confirmada proxima');
INSERT INTO estado_bicicleta (nombre, permite_reserva, descripcion)
VALUES ('En renta', 'N', 'Entregada actualmente a un cliente');
INSERT INTO estado_bicicleta (nombre, permite_reserva, descripcion)
VALUES ('En revision', 'N', 'En inspeccion tecnica tras devolucion');
INSERT INTO estado_bicicleta (nombre, permite_reserva, descripcion)
VALUES ('En mantenimiento', 'N', 'Ingresada en taller por reparacion o servicio');
INSERT INTO estado_bicicleta (nombre, permite_reserva, descripcion)
VALUES ('Fuera de servicio', 'N', 'Inhabilitada temporalmente por dano mayor');
INSERT INTO estado_bicicleta (nombre, permite_reserva, descripcion)
VALUES ('Dada de baja', 'N', 'Retirada definitivamente del inventario activo');

INSERT INTO estado_reserva (nombre, bloquea_inventario) VALUES ('Pendiente de pago', 'S');
INSERT INTO estado_reserva (nombre, bloquea_inventario) VALUES ('Confirmada', 'S');
INSERT INTO estado_reserva (nombre, bloquea_inventario) VALUES ('En curso', 'S');
INSERT INTO estado_reserva (nombre, bloquea_inventario) VALUES ('Finalizada', 'N');
INSERT INTO estado_reserva (nombre, bloquea_inventario) VALUES ('Cancelada', 'N');
INSERT INTO estado_reserva (nombre, bloquea_inventario) VALUES ('No presentada', 'N');

INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
VALUES (1, 45.00, 270.00, DATE '2026-01-01', DATE '2026-06-30');
INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
VALUES (1, 50.00, 300.00, DATE '2026-07-01', NULL);
INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
VALUES (2, 70.00, 420.00, DATE '2026-01-01', NULL);
INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
VALUES (3, 85.00, 510.00, DATE '2026-01-01', NULL);
INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
VALUES (4, 120.00, 750.00, DATE '2026-01-01', NULL);
INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
VALUES (5, 90.00, 540.00, DATE '2026-01-01', NULL);
INSERT INTO tarifa (id_tipo, precio_hora, precio_dia, vigente_desde, vigente_hasta)
VALUES (6, 35.00, 200.00, DATE '2026-01-01', NULL);

INSERT INTO temporada (nombre, fecha_inicio, fecha_fin, porcentaje_incremento)
VALUES ('Semana Santa 2026', DATE '2026-03-29', DATE '2026-04-05', 15.00);
INSERT INTO temporada (nombre, fecha_inicio, fecha_fin, porcentaje_incremento)
VALUES ('Guelaguetza 2026', DATE '2026-07-17', DATE '2026-07-28', 25.00);
INSERT INTO temporada (nombre, fecha_inicio, fecha_fin, porcentaje_incremento)
VALUES ('Dia de Muertos 2026', DATE '2026-10-28', DATE '2026-11-03', 20.00);
INSERT INTO temporada (nombre, fecha_inicio, fecha_fin, porcentaje_incremento)
VALUES ('Decembrina 2026', DATE '2026-12-18', DATE '2027-01-03', 15.00);

INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('ADMINISTRADOR', 'admin@canteraypedal.mx', '$2b$12$hashAdminCiclito202600000000000000000000000001', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('EMPLEADO', 'lupita.ruiz@canteraypedal.mx', '$2b$12$hashEmpLupita2026000000000000000000000000002', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('EMPLEADO', 'carlos.mendez@canteraypedal.mx', '$2b$12$hashEmpCarlos2026000000000000000000000000003', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('EMPLEADO', 'sofia.ramirez@canteraypedal.mx', '$2b$12$hashEmpSofia20260000000000000000000000000004', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('CLIENTE', 'emma.schneider@mail.de', '$2b$12$hashCliEmma2026000000000000000000000000000005', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('CLIENTE', 'diego.lopez@gmail.com', '$2b$12$hashCliDiego20260000000000000000000000000006', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('CLIENTE', 'valeria.santos@hotmail.com', '$2b$12$hashCliValeria20260000000000000000000000007', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('CLIENTE', 'john.miller@outlook.com', '$2b$12$hashCliJohn2026000000000000000000000000000008', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('CLIENTE', 'claire.dubois@orange.fr', '$2b$12$hashCliClaire202600000000000000000000000009', 'ACTIVA');
INSERT INTO usuario (rol, correo, password_hash, estado_cuenta)
VALUES ('CLIENTE', 'mateo.ortiz@yahoo.com', '$2b$12$hashCliMateo20260000000000000000000000000010', 'BLOQUEADA');

INSERT INTO empleado (id_usuario, id_sucursal, nombres, apellidos, telefono, puesto)
VALUES (1, 1, 'Roberto', 'Guzman Silva', '9511100001', 'Gerente General');
INSERT INTO empleado (id_usuario, id_sucursal, nombres, apellidos, telefono, puesto)
VALUES (2, 1, 'Lupita', 'Ruiz Hernandez', '9511100002', 'Mostrador');
INSERT INTO empleado (id_usuario, id_sucursal, nombres, apellidos, telefono, puesto)
VALUES (3, 2, 'Carlos', 'Mendez Perez', '9511100003', 'Mecanico');
INSERT INTO empleado (id_usuario, id_sucursal, nombres, apellidos, telefono, puesto)
VALUES (4, 3, 'Sofia', 'Ramirez Cruz', '9511100004', 'Mostrador');

INSERT INTO cliente (id_usuario, id_pais, tipo_identificacion, numero_identificacion, nombres, apellidos, telefono, fecha_nacimiento)
VALUES (5, 2, 'PASAPORTE', 'C4F7X92K1', 'Emma', 'Schneider', '+491601234567', DATE '1993-03-14');
INSERT INTO cliente (id_usuario, id_pais, tipo_identificacion, numero_identificacion, nombres, apellidos, telefono, fecha_nacimiento)
VALUES (6, 1, 'INE', 'LPZD980512HOX01', 'Diego', 'Lopez Zarate', '9512203344', DATE '1998-05-12');
INSERT INTO cliente (id_usuario, id_pais, tipo_identificacion, numero_identificacion, nombres, apellidos, telefono, fecha_nacimiento)
VALUES (7, 1, 'INE', 'SNVL010922MOX02', 'Valeria', 'Santos Nava', '9513304455', DATE '2001-09-22');
INSERT INTO cliente (id_usuario, id_pais, tipo_identificacion, numero_identificacion, nombres, apellidos, telefono, fecha_nacimiento)
VALUES (8, 3, 'PASAPORTE', '561892340', 'John', 'Miller', '+15125550199', DATE '1987-11-04');
INSERT INTO cliente (id_usuario, id_pais, tipo_identificacion, numero_identificacion, nombres, apellidos, telefono, fecha_nacimiento)
VALUES (9, 6, 'PASAPORTE', '19FR88210', 'Claire', 'Dubois', '+33612345678', DATE '1995-07-19');
INSERT INTO cliente (id_usuario, id_pais, tipo_identificacion, numero_identificacion, nombres, apellidos, telefono, fecha_nacimiento)
VALUES (10, 1, 'LICENCIA', 'OAX-998123', 'Mateo', 'Ortiz Blas', '9514405566', DATE '1999-02-10');

INSERT INTO contacto_emergencia (id_cliente, nombre_completo, parentesco, telefono)
VALUES (1, 'Lukas Schneider', 'Hermano', '+491609876543');
INSERT INTO contacto_emergencia (id_cliente, nombre_completo, parentesco, telefono)
VALUES (2, 'Maria Zarate', 'Madre', '9512203399');
INSERT INTO contacto_emergencia (id_cliente, nombre_completo, parentesco, telefono)
VALUES (3, 'Jorge Santos', 'Padre', '9513304400');
INSERT INTO contacto_emergencia (id_cliente, nombre_completo, parentesco, telefono)
VALUES (4, 'Sarah Miller', 'Esposa', '+15125550188');
INSERT INTO contacto_emergencia (id_cliente, nombre_completo, parentesco, telefono)
VALUES (5, 'Marc Dubois', 'Padre', '+33687654321');
INSERT INTO contacto_emergencia (id_cliente, nombre_completo, parentesco, telefono)
VALUES (6, 'Elena Blas', 'Madre', '9514405500');

INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('URB-001', 'SN-BEN-2024-001', 1, 1, 1, 'Benotto', 'Clasica', 26.0, 'M', 'Verde Olivo', 2024, DATE '2024-02-15', 5800.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('URB-004', 'SN-BEN-2024-004', 1, 1, 2, 'Benotto', 'Clasica', 26.0, 'M', 'Azul', 2024, DATE '2024-02-15', 5800.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('URB-011', 'SN-ALU-2024-011', 1, 1, 2, 'Alubike', 'City', 26.0, 'S', 'Rojo', 2024, DATE '2024-03-10', 6400.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('MTB-001', 'SN-TRK-2023-101', 2, 1, 1, 'Trek', 'Marlin 5', 29.0, 'L', 'Negro Mate', 2023, DATE '2023-05-20', 13500.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('MTB-002', 'SN-SPC-2024-102', 2, 3, 2, 'Specialized', 'Rockhopper', 29.0, 'M', 'Vino', 2024, DATE '2024-01-18', 14800.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('RUT-001', 'SN-GIA-2024-201', 3, 1, 1, 'Giant', 'Contend 3', 28.0, '54 cm', 'Gris', 2024, DATE '2024-04-02', 18200.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('ELE-001', 'SN-MER-2025-301', 4, 1, 1, 'Mercurio', 'E-Volt', 27.5, 'M', 'Blanco', 2025, DATE '2025-01-12', 24500.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('ELE-002', 'SN-MER-2025-302', 4, 5, 2, 'Mercurio', 'E-Volt', 27.5, 'M', 'Negro', 2025, DATE '2025-01-12', 24500.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('TAN-001', 'SN-SCH-2022-401', 5, 1, 3, 'Schwinn', 'Twinn Classic', 26.0, 'M/S', 'Crema', 2022, DATE '2022-06-05', 15900.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('INF-001', 'SN-BEN-2024-501', 6, 1, 3, 'Benotto', 'Junior R20', 20.0, 'XS', 'Naranja', 2024, DATE '2024-06-15', 3600.00);
INSERT INTO bicicleta (codigo_interno, num_serie, id_tipo, id_estado_actual, id_sucursal_actual, marca, modelo, rodada, talla_cuadro, color, anio, fecha_adquisicion, costo_adquisicion)
VALUES ('URB-015', 'SN-BEN-2021-015', 1, 6, 1, 'Benotto', 'Paseo', 26.0, 'M', 'Azul Marino', 2021, DATE '2021-08-10', 4900.00);

INSERT INTO bicicleta_electrica (id_bicicleta, autonomia_km, capacidad_bateria_wh) VALUES (7, 65.0, 500.0);
INSERT INTO bicicleta_electrica (id_bicicleta, autonomia_km, capacidad_bateria_wh) VALUES (8, 65.0, 500.0);

INSERT INTO historial_estado_bici (id_bicicleta, id_estado_anterior, id_estado_nuevo, id_usuario, motivo)
VALUES (2, 3, 1, 2, 'Devolucion recibida y liberada en sucursal El Llano');
INSERT INTO historial_estado_bici (id_bicicleta, id_estado_anterior, id_estado_nuevo, id_usuario, motivo)
VALUES (8, 4, 5, 3, 'Falla detectada en freno trasero durante devolucion R-2026-0147');
INSERT INTO historial_estado_bici (id_bicicleta, id_estado_anterior, id_estado_nuevo, id_usuario, motivo)
VALUES (5, 1, 3, 2, 'Entrega en mostrador para reserva R-2026-0150');

INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Frenos', 'Verificar tension de chicotes, desgaste de zapatas o pastillas y frenado firme');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Llantas', 'Revisar presion recomendada, dibujo de rodadura y ausencia de grietas');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Cadena', 'Comprobar lubricacion, tension y ausencia de eslabones trabados');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Cambios', 'Probar transicion suave de velocidades y alineacion del desviador');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Luces', 'Encendido correcto de luz delantera blanca y trasera roja');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Asiento', 'Ajuste firme de poste, abrazadera y estado del sillin');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Cuadro', 'Inspeccion visual de soldaduras, horquilla y manubrio sin fisuras');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Timbre', 'Funcionamiento audible del timbre o claxon');
INSERT INTO punto_inspeccion (nombre, descripcion) VALUES ('Bateria', 'Nivel de carga superior al 80% y anclaje seguro de bateria');

INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (1, 1);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (2, 1);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (3, 1);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (5, 1);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (6, 1);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (7, 1);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (8, 1);

INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (1, 2);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (2, 2);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (3, 2);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (4, 2);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (6, 2);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (7, 2);

INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (1, 3);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (2, 3);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (3, 3);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (4, 3);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (6, 3);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (7, 3);

INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (1, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (2, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (3, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (4, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (5, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (6, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (7, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (8, 4);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (9, 4);

INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (1, 5);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (2, 5);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (3, 5);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (4, 5);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (6, 5);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (7, 5);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (8, 5);

INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (1, 6);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (2, 6);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (3, 6);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (6, 6);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (7, 6);
INSERT INTO punto_inspeccion_tipo (id_punto, id_tipo) VALUES (8, 6);

INSERT INTO reserva (folio, id_cliente, id_sucursal_recogida, id_sucursal_devolucion, id_estado_res, id_temporada, id_empleado_entrega, id_empleado_devolucion, fecha_creacion, fecha_inicio_prog, fecha_fin_prog, fecha_recogida_real, fecha_devolucion_real, porcentaje_temp_aplicado, total_estimado)
VALUES ('R-2026-0147', 1, 1, 2, 4, 3, 2, 2, TO_DATE('2026-10-28 18:42', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-01 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-01 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-01 09:05', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-01 17:50', 'YYYY-MM-DD HH24:MI'), 20.00, 1320.00);

INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal, recargo_retraso, cargo_dano)
VALUES (1, 2, 50.00, 300.00, 500.00, 1, 0, 300.00, 0.00, 0.00);
INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal, recargo_retraso, cargo_dano)
VALUES (1, 3, 50.00, 300.00, 500.00, 1, 0, 300.00, 0.00, 0.00);
INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal, recargo_retraso, cargo_dano)
VALUES (1, 8, 120.00, 750.00, 3000.00, 1, 0, 750.00, 0.00, 150.00);

INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (1, NULL, 'TARJETA', 'ANTICIPO', 396.00, 'AUTH-4512');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (1, 2, 'EFECTIVO', 'SALDO_RENTA', 924.00, 'REC-0147-S');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (1, 2, 'TARJETA', 'DEPOSITO', 4000.00, 'DEP-8821');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (1, 2, 'EFECTIVO', 'CARGO_DANO', 150.00, 'DAN-0147');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (1, 2, 'TARJETA', 'DEVOLUCION_DEPOSITO', 3850.00, 'DEV-8821');

INSERT INTO reserva (folio, id_cliente, id_sucursal_recogida, id_sucursal_devolucion, id_estado_res, id_temporada, id_empleado_entrega, id_empleado_devolucion, fecha_creacion, fecha_inicio_prog, fecha_fin_prog, fecha_recogida_real, fecha_devolucion_real, porcentaje_temp_aplicado, total_estimado)
VALUES ('R-2026-0148', 2, 1, 1, 4, NULL, 2, 2, TO_DATE('2026-11-10 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-11 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-11 13:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-11 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-11 14:40', 'YYYY-MM-DD HH24:MI'), 0.00, 340.00);

INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal, recargo_retraso, cargo_dano)
VALUES (2, 6, 85.00, 510.00, 1500.00, 0, 4, 340.00, 255.00, 0.00);

INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (2, NULL, 'TRANSFERENCIA', 'ANTICIPO', 102.00, 'SPEI-9901');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (2, 2, 'EFECTIVO', 'SALDO_RENTA', 238.00, 'REC-0148-S');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (2, 2, 'EFECTIVO', 'RECARGO_RETRASO', 255.00, 'RET-0148');

INSERT INTO reserva (folio, id_cliente, id_sucursal_recogida, id_sucursal_devolucion, id_estado_res, id_temporada, id_empleado_entrega, fecha_creacion, fecha_inicio_prog, fecha_fin_prog, fecha_recogida_real, porcentaje_temp_aplicado, total_estimado)
VALUES ('R-2026-0150', 4, 2, 2, 3, NULL, 2, SYSDATE - 1, SYSDATE - (2/24), SYSDATE + (4/24), SYSDATE - (2/24), 0.00, 420.00);

INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal)
VALUES (3, 5, 70.00, 420.00, 1000.00, 0, 6, 420.00);

INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (3, NULL, 'TARJETA', 'ANTICIPO', 126.00, 'AUTH-7720');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (3, 2, 'TARJETA', 'SALDO_RENTA', 294.00, 'AUTH-7725');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (3, 2, 'TARJETA', 'DEPOSITO', 1000.00, 'DEP-7726');

INSERT INTO reserva (folio, id_cliente, id_sucursal_recogida, id_sucursal_devolucion, id_estado_res, id_temporada, fecha_creacion, fecha_inicio_prog, fecha_fin_prog, porcentaje_temp_aplicado, total_estimado)
VALUES ('R-2026-0151', 3, 3, 3, 2, NULL, SYSDATE, SYSDATE + 2, SYSDATE + 3, 0.00, 740.00);

INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal)
VALUES (4, 9, 90.00, 540.00, 1200.00, 1, 0, 540.00);
INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal)
VALUES (4, 10, 35.00, 200.00, 400.00, 1, 0, 200.00);

INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (4, NULL, 'TARJETA', 'ANTICIPO', 222.00, 'AUTH-8100');

INSERT INTO reserva (folio, id_cliente, id_sucursal_recogida, id_sucursal_devolucion, id_estado_res, id_temporada, fecha_creacion, fecha_inicio_prog, fecha_fin_prog, fecha_cancelacion, porcentaje_temp_aplicado, total_estimado)
VALUES ('R-2026-0149', 5, 1, 1, 5, NULL, DATE '2026-11-12', DATE '2026-11-16', DATE '2026-11-17', DATE '2026-11-13', 0.00, 750.00);

INSERT INTO detalle_reserva (id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado, deposito_aplicado, dias_cobrados, horas_cobradas, subtotal)
VALUES (5, 7, 120.00, 750.00, 3000.00, 1, 0, 750.00);

INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (5, NULL, 'TARJETA', 'ANTICIPO', 225.00, 'AUTH-6001');
INSERT INTO pago (id_reserva, id_empleado, metodo_pago, concepto_pago, monto, referencia)
VALUES (5, 2, 'TRANSFERENCIA', 'REEMBOLSO_ANTICIPO', 225.00, 'REM-6001');

INSERT INTO revision (id_bicicleta, id_empleado, id_reserva, tipo_revision, fecha_hora, resultado_global, observaciones)
VALUES (8, 2, 1, 'ENTREGA', TO_DATE('2026-11-01 09:00', 'YYYY-MM-DD HH24:MI'), 'CORRECTO', 'Bateria al 95%, sistema electrico optimo');
INSERT INTO revision (id_bicicleta, id_empleado, id_reserva, tipo_revision, fecha_hora, resultado_global, observaciones)
VALUES (8, 2, 1, 'DEVOLUCION', TO_DATE('2026-11-01 17:55', 'YYYY-MM-DD HH24:MI'), 'FALLA', 'Freno trasero sin presion por desgaste severo de balatas');

INSERT INTO detalle_revision (id_revision, id_punto, resultado, comentario) VALUES (1, 1, 'CORRECTO', 'Frenos firmes');
INSERT INTO detalle_revision (id_revision, id_punto, resultado, comentario) VALUES (1, 9, 'CORRECTO', 'Carga al 95%');
INSERT INTO detalle_revision (id_revision, id_punto, resultado, comentario) VALUES (2, 1, 'FALLA', 'Balata trasera cristalizada y chicote destensado');
INSERT INTO detalle_revision (id_revision, id_punto, resultado, comentario) VALUES (2, 2, 'CORRECTO', 'Presion correcta');

INSERT INTO orden_mantenimiento (id_bicicleta, id_empleado, id_revision_origen, diagnostico, descripcion_trabajo, costo_mano_obra, fecha_inicio, estado_orden)
VALUES (8, 3, 2, 'Falla en freno de disco trasero reportada en devolucion R-2026-0147', 'Cambio de juego de balatas traseras y purga de linea', 180.00, TO_DATE('2026-11-02', 'YYYY-MM-DD'), 'EN_PROCESO');

INSERT INTO detalle_mantenimiento (id_orden, nombre_refaccion, cantidad, costo_unitario)
VALUES (1, 'Juego de balatas semimetalicas', 1, 220.00);
INSERT INTO detalle_mantenimiento (id_orden, nombre_refaccion, cantidad, costo_unitario)
VALUES (1, 'Liquido de frenos mineral 100ml', 1, 95.00);

COMMIT;