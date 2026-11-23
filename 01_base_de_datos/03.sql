CREATE OR REPLACE VIEW vw_flota_disponible AS
SELECT
    b.id_bicicleta,
    b.codigo_interno,
    b.num_serie,
    tb.nombre AS tipo_bicicleta,
    b.marca,
    b.modelo,
    b.rodada,
    b.talla_cuadro,
    b.color,
    s.id_sucursal,
    s.nombre AS sucursal_actual,
    eb.nombre AS estado_actual,
    t.precio_hora,
    t.precio_dia,
    tb.deposito_garantia,
    be.autonomia_km,
    be.capacidad_bateria_wh
FROM bicicleta b
JOIN tipo_bicicleta tb ON b.id_tipo = tb.id_tipo
JOIN sucursal s ON b.id_sucursal_actual = s.id_sucursal
JOIN estado_bicicleta eb ON b.id_estado_actual = eb.id_estado_bici
LEFT JOIN tarifa t ON t.id_tipo = tb.id_tipo AND t.vigente_hasta IS NULL
LEFT JOIN bicicleta_electrica be ON b.id_bicicleta = be.id_bicicleta
WHERE eb.permite_reserva = 'S';

CREATE OR REPLACE VIEW vw_resumen_reservas AS
SELECT
    r.id_reserva,
    r.folio,
    er.nombre AS estado_reserva,
    c.nombres || ' ' || c.apellidos AS cliente,
    u.correo AS correo_cliente,
    p.nombre AS pais_origen,
    sr.nombre AS sucursal_recogida,
    sd.nombre AS sucursal_devolucion,
    r.fecha_inicio_prog,
    r.fecha_fin_prog,
    r.fecha_recogida_real,
    r.fecha_devolucion_real,
    NVL(temp.nombre, 'Temporada Regular') AS temporada,
    r.porcentaje_temp_aplicado,
    r.total_estimado,
    COUNT(dr.id_detalle_res) AS total_bicicletas,
    NVL(SUM(dr.recargo_retraso), 0) AS total_recargos,
    NVL(SUM(dr.cargo_dano), 0) AS total_danos
FROM reserva r
JOIN estado_reserva er ON r.id_estado_res = er.id_estado_res
JOIN cliente c ON r.id_cliente = c.id_cliente
JOIN usuario u ON c.id_usuario = u.id_usuario
JOIN pais p ON c.id_pais = p.id_pais
JOIN sucursal sr ON r.id_sucursal_recogida = sr.id_sucursal
JOIN sucursal sd ON r.id_sucursal_devolucion = sd.id_sucursal
LEFT JOIN temporada temp ON r.id_temporada = temp.id_temporada
LEFT JOIN detalle_reserva dr ON r.id_reserva = dr.id_reserva
GROUP BY
    r.id_reserva, r.folio, er.nombre, c.nombres, c.apellidos, u.correo, p.nombre,
    sr.nombre, sd.nombre, r.fecha_inicio_prog, r.fecha_fin_prog, r.fecha_recogida_real,
    r.fecha_devolucion_real, temp.nombre, r.porcentaje_temp_aplicado, r.total_estimado;

CREATE OR REPLACE VIEW vw_ingresos_sucursal_mes AS
SELECT
    s.id_sucursal,
    s.nombre AS sucursal,
    TO_CHAR(pg.fecha_hora, 'YYYY-MM') AS anio_mes,
    SUM(CASE WHEN pg.concepto_pago IN ('ANTICIPO', 'SALDO_RENTA', 'RECARGO_RETRASO', 'CARGO_DANO') THEN pg.monto ELSE 0 END) AS ingresos_brutos,
    SUM(CASE WHEN pg.concepto_pago = 'REEMBOLSO_ANTICIPO' THEN pg.monto ELSE 0 END) AS reembolsos,
    SUM(CASE WHEN pg.concepto_pago IN ('ANTICIPO', 'SALDO_RENTA', 'RECARGO_RETRASO', 'CARGO_DANO') THEN pg.monto
             WHEN pg.concepto_pago = 'REEMBOLSO_ANTICIPO' THEN -pg.monto
             ELSE 0 END) AS ingreso_neto
FROM sucursal s
JOIN reserva r ON r.id_sucursal_recogida = s.id_sucursal
JOIN pago pg ON pg.id_reserva = r.id_reserva
GROUP BY s.id_sucursal, s.nombre, TO_CHAR(pg.fecha_hora, 'YYYY-MM');

CREATE OR REPLACE FUNCTION fn_calcular_costo_bici (
    p_id_tipo       IN NUMBER,
    p_fecha_inicio  IN DATE,
    p_fecha_fin     IN DATE
) RETURN NUMBER IS
    v_precio_hora  NUMBER(8,2);
    v_precio_dia   NUMBER(8,2);
    v_pct_temp     NUMBER(5,2) := 0;
    v_horas_tot    NUMBER;
    v_dias         NUMBER;
    v_horas_rest   NUMBER;
    v_base         NUMBER(10,2);
BEGIN
    IF p_fecha_fin <= p_fecha_inicio THEN
        RAISE_APPLICATION_ERROR(-20001, 'La fecha de fin debe ser posterior a la fecha de inicio.');
    END IF;

    SELECT precio_hora, precio_dia
      INTO v_precio_hora, v_precio_dia
      FROM tarifa
     WHERE id_tipo = p_id_tipo
       AND vigente_desde <= TRUNC(p_fecha_inicio)
       AND (vigente_hasta IS NULL OR vigente_hasta >= TRUNC(p_fecha_inicio))
     FETCH FIRST 1 ROW ONLY;

    SELECT NVL(MAX(porcentaje_incremento), 0)
      INTO v_pct_temp
      FROM temporada
     WHERE TRUNC(p_fecha_inicio) BETWEEN fecha_inicio AND fecha_fin;

    v_horas_tot := CEIL((p_fecha_fin - p_fecha_inicio) * 24);
    v_dias := FLOOR(v_horas_tot / 24);
    v_horas_rest := MOD(v_horas_tot, 24);

    IF (v_horas_rest * v_precio_hora) >= v_precio_dia THEN
        v_dias := v_dias + 1;
        v_horas_rest := 0;
    END IF;

    v_base := (v_dias * v_precio_dia) + (v_horas_rest * v_precio_hora);
    RETURN ROUND(v_base * (1 + (v_pct_temp / 100)), 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No existe tarifa vigente para el tipo de bicicleta indicado.');
END fn_calcular_costo_bici;
/

CREATE OR REPLACE PROCEDURE sp_crear_reserva (
    p_id_cliente             IN  NUMBER,
    p_id_sucursal_recogida   IN  NUMBER,
    p_id_sucursal_devolucion IN  NUMBER,
    p_fecha_inicio           IN  DATE,
    p_fecha_fin              IN  DATE,
    p_ids_bicicletas         IN  SYS.ODCINUMBERLIST,
    p_id_reserva_out         OUT NUMBER,
    p_folio_out              OUT VARCHAR2
) IS
    v_fecha_nac      DATE;
    v_estado_cuenta  VARCHAR2(10);
    v_duracion_horas NUMBER;
    v_traslapes      NUMBER;
    v_permite_res    CHAR(1);
    v_sucursal_bici  NUMBER(5);
    v_id_tipo        NUMBER(5);
    v_precio_hora    NUMBER(8,2);
    v_precio_dia     NUMBER(8,2);
    v_deposito       NUMBER(8,2);
    v_id_temporada   NUMBER(5);
    v_pct_temp       NUMBER(5,2) := 0;
    v_dias           NUMBER;
    v_horas_rest     NUMBER;
    v_subtotal_bici  NUMBER(10,2);
    v_total_reserva  NUMBER(10,2) := 0;
    v_id_estado_pend NUMBER(5);
    v_id_estado_resv NUMBER(5);
    v_id_usr_cliente NUMBER(10);
BEGIN
    IF p_ids_bicicletas IS NULL OR p_ids_bicicletas.COUNT = 0 OR p_ids_bicicletas.COUNT > 5 THEN
        RAISE_APPLICATION_ERROR(-20010, 'RN-02: Una reserva debe incluir entre 1 y 5 bicicletas.');
    END IF;

    SELECT c.fecha_nacimiento, u.estado_cuenta, u.id_usuario
      INTO v_fecha_nac, v_estado_cuenta, v_id_usr_cliente
      FROM cliente c
      JOIN usuario u ON c.id_usuario = u.id_usuario
     WHERE c.id_cliente = p_id_cliente;

    IF v_estado_cuenta <> 'ACTIVA' THEN
        RAISE_APPLICATION_ERROR(-20011, 'La cuenta del cliente se encuentra bloqueada.');
    END IF;

    IF MONTHS_BETWEEN(TRUNC(SYSDATE), v_fecha_nac) / 12 < 18 THEN
        RAISE_APPLICATION_ERROR(-20012, 'RN-01: El cliente debe ser mayor de 18 anos para reservar.');
    END IF;

    v_duracion_horas := (p_fecha_fin - p_fecha_inicio) * 24;
    IF p_fecha_inicio < SYSDATE OR v_duracion_horas < 1 OR v_duracion_horas > 168 THEN
        RAISE_APPLICATION_ERROR(-20013, 'RN-04: La duracion debe estar entre 1 hora y 7 dias en fecha futura.');
    END IF;

    BEGIN
        SELECT id_temporada, porcentaje_incremento
          INTO v_id_temporada, v_pct_temp
          FROM temporada
         WHERE TRUNC(p_fecha_inicio) BETWEEN fecha_inicio AND fecha_fin
         FETCH FIRST 1 ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_id_temporada := NULL;
            v_pct_temp := 0;
    END;

    SELECT id_estado_res INTO v_id_estado_pend
      FROM estado_reserva WHERE nombre = 'Pendiente de pago';
    SELECT id_estado_bici INTO v_id_estado_resv
      FROM estado_bicicleta WHERE nombre = 'Reservada';

    p_folio_out := 'R-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1000, 9999)), 4, '0');

    INSERT INTO reserva (
        folio, id_cliente, id_sucursal_recogida, id_sucursal_devolucion,
        id_estado_res, id_temporada, fecha_inicio_prog, fecha_fin_prog,
        porcentaje_temp_aplicado, total_estimado
    ) VALUES (
        p_folio_out, p_id_cliente, p_id_sucursal_recogida, p_id_sucursal_devolucion,
        v_id_estado_pend, v_id_temporada, p_fecha_inicio, p_fecha_fin,
        v_pct_temp, 0
    ) RETURNING id_reserva INTO p_id_reserva_out;

    FOR i IN 1 .. p_ids_bicicletas.COUNT LOOP
        SELECT b.id_tipo, b.id_sucursal_actual, eb.permite_reserva, tb.deposito_garantia
          INTO v_id_tipo, v_sucursal_bici, v_permite_res, v_deposito
          FROM bicicleta b
          JOIN estado_bicicleta eb ON b.id_estado_actual = eb.id_estado_bici
          JOIN tipo_bicicleta tb ON b.id_tipo = tb.id_tipo
         WHERE b.id_bicicleta = p_ids_bicicletas(i)
           FOR UPDATE;

        IF v_permite_res <> 'S' OR v_sucursal_bici <> p_id_sucursal_recogida THEN
            RAISE_APPLICATION_ERROR(-20014, 'RN-03: Bicicleta no disponible en la sucursal de recogida.');
        END IF;

        SELECT COUNT(*)
          INTO v_traslapes
          FROM detalle_reserva dr
          JOIN reserva r ON dr.id_reserva = r.id_reserva
          JOIN estado_reserva er ON r.id_estado_res = er.id_estado_res
         WHERE dr.id_bicicleta = p_ids_bicicletas(i)
           AND er.bloquea_inventario = 'S'
           AND p_fecha_inicio < r.fecha_fin_prog
           AND p_fecha_fin > r.fecha_inicio_prog;

        IF v_traslapes > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'RN-02: La bicicleta ya tiene una reserva traslapada en ese horario.');
        END IF;

        SELECT precio_hora, precio_dia
          INTO v_precio_hora, v_precio_dia
          FROM tarifa
         WHERE id_tipo = v_id_tipo
           AND vigente_desde <= TRUNC(p_fecha_inicio)
           AND (vigente_hasta IS NULL OR vigente_hasta >= TRUNC(p_fecha_inicio))
         FETCH FIRST 1 ROW ONLY;

        v_dias := FLOOR(CEIL(v_duracion_horas) / 24);
        v_horas_rest := MOD(CEIL(v_duracion_horas), 24);
        IF (v_horas_rest * v_precio_hora) >= v_precio_dia THEN
            v_dias := v_dias + 1;
            v_horas_rest := 0;
        END IF;

        v_subtotal_bici := (v_dias * v_precio_dia) + (v_horas_rest * v_precio_hora);
        v_total_reserva := v_total_reserva + ROUND(v_subtotal_bici * (1 + (v_pct_temp / 100)), 2);

        INSERT INTO detalle_reserva (
            id_reserva, id_bicicleta, precio_hora_aplicado, precio_dia_aplicado,
            deposito_aplicado, dias_cobrados, horas_cobradas, subtotal
        ) VALUES (
            p_id_reserva_out, p_ids_bicicletas(i), v_precio_hora, v_precio_dia,
            v_deposito, v_dias, v_horas_rest, v_subtotal_bici
        );

        UPDATE bicicleta
           SET id_estado_actual = v_id_estado_resv
         WHERE id_bicicleta = p_ids_bicicletas(i);
    END LOOP;

    UPDATE reserva
       SET total_estimado = v_total_reserva
     WHERE id_reserva = p_id_reserva_out;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_crear_reserva;
/

CREATE OR REPLACE TRIGGER trg_bici_historial_estado
AFTER INSERT OR UPDATE OF id_estado_actual ON bicicleta
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO historial_estado_bici (id_bicicleta, id_estado_anterior, id_estado_nuevo, motivo)
        VALUES (:NEW.id_bicicleta, NULL, :NEW.id_estado_actual, 'Alta inicial en inventario');
    ELSIF :OLD.id_estado_actual <> :NEW.id_estado_actual THEN
        INSERT INTO historial_estado_bici (id_bicicleta, id_estado_anterior, id_estado_nuevo, motivo)
        VALUES (:NEW.id_bicicleta, :OLD.id_estado_actual, :NEW.id_estado_actual, 'Actualizacion operativa de estado');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_detalle_revision_falla
AFTER INSERT OR UPDATE OF resultado ON detalle_revision
FOR EACH ROW
WHEN (NEW.resultado = 'FALLA')
DECLARE
    v_id_bicicleta   NUMBER(10);
    v_id_estado_fs   NUMBER(5);
BEGIN
    SELECT id_bicicleta INTO v_id_bicicleta
      FROM revision
     WHERE id_revision = :NEW.id_revision;

    SELECT id_estado_bici INTO v_id_estado_fs
      FROM estado_bicicleta
     WHERE nombre = 'Fuera de servicio';

    UPDATE revision
       SET resultado_global = 'FALLA'
     WHERE id_revision = :NEW.id_revision;

    UPDATE bicicleta
       SET id_estado_actual = v_id_estado_fs
     WHERE id_bicicleta = v_id_bicicleta;
END;
/

SELECT * FROM vw_flota_disponible WHERE sucursal_actual = 'Centro Historico' ORDER BY tipo_bicicleta, codigo_interno;

SELECT * FROM vw_resumen_reservas ORDER BY fecha_inicio_prog DESC;

SELECT * FROM vw_ingresos_sucursal_mes ORDER BY anio_mes DESC, ingreso_neto DESC;

SELECT tb.nombre AS tipo_bicicleta, COUNT(dr.id_detalle_res) AS veces_rentada, SUM(dr.subtotal) AS ingreso_base
FROM tipo_bicicleta tb
JOIN bicicleta b ON b.id_tipo = tb.id_tipo
JOIN detalle_reserva dr ON dr.id_bicicleta = b.id_bicicleta
GROUP BY tb.nombre
ORDER BY veces_rentada DESC;

SELECT c.nombres || ' ' || c.apellidos AS cliente, p.nombre AS pais, COUNT(r.id_reserva) AS total_reservas, SUM(r.total_estimado) AS gasto_total
FROM cliente c
JOIN pais p ON c.id_pais = p.id_pais
JOIN reserva r ON r.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombres, c.apellidos, p.nombre
ORDER BY gasto_total DESC;

SELECT om.id_orden, b.codigo_interno, b.marca || ' ' || b.modelo AS bicicleta, om.estado_orden,
       om.costo_mano_obra, NVL(SUM(dm.cantidad * dm.costo_unitario), 0) AS costo_refacciones,
       om.costo_mano_obra + NVL(SUM(dm.cantidad * dm.costo_unitario), 0) AS costo_total_taller
FROM orden_mantenimiento om
JOIN bicicleta b ON om.id_bicicleta = b.id_bicicleta
LEFT JOIN detalle_mantenimiento dm ON dm.id_orden = om.id_orden
WHERE om.estado_orden IN ('ABIERTA', 'EN_PROCESO')
GROUP BY om.id_orden, b.codigo_interno, b.marca, b.modelo, om.estado_orden, om.costo_mano_obra;

SELECT r.folio, c.nombres || ' ' || c.apellidos AS cliente, b.codigo_interno,
       ROUND((r.fecha_devolucion_real - r.fecha_fin_prog) * 24, 2) AS horas_retraso,
       dr.recargo_retraso
FROM reserva r
JOIN cliente c ON r.id_cliente = c.id_cliente
JOIN detalle_reserva dr ON dr.id_reserva = r.id_reserva
JOIN bicicleta b ON b.id_bicicleta = dr.id_bicicleta
WHERE r.fecha_devolucion_real > r.fecha_fin_prog;

SELECT b.codigo_interno, ea.nombre AS estado_anterior, en.nombre AS estado_nuevo, h.fecha_hora, h.motivo
FROM historial_estado_bici h
JOIN bicicleta b ON h.id_bicicleta = b.id_bicicleta
LEFT JOIN estado_bicicleta ea ON h.id_estado_anterior = ea.id_estado_bici
JOIN estado_bicicleta en ON h.id_estado_nuevo = en.id_estado_bici
ORDER BY b.codigo_interno, h.fecha_hora DESC;

SELECT b.codigo_interno, tb.nombre AS tipo, b.marca, b.modelo, b.fecha_adquisicion,
       TRUNC(MONTHS_BETWEEN(SYSDATE, b.fecha_adquisicion) / 12, 1) AS anos_servicio, eb.nombre AS estado
FROM bicicleta b
JOIN tipo_bicicleta tb ON b.id_tipo = tb.id_tipo
JOIN estado_bicicleta eb ON b.id_estado_actual = eb.id_estado_bici
WHERE MONTHS_BETWEEN(SYSDATE, b.fecha_adquisicion) >= 36
ORDER BY b.fecha_adquisicion ASC;

SELECT r.folio, r.total_estimado,
       SUM(CASE WHEN pg.concepto_pago IN ('ANTICIPO', 'SALDO_RENTA') THEN pg.monto ELSE 0 END) AS renta_cobrada,
       SUM(CASE WHEN pg.concepto_pago = 'DEPOSITO' THEN pg.monto ELSE 0 END) AS deposito_recibido,
       SUM(CASE WHEN pg.concepto_pago = 'DEVOLUCION_DEPOSITO' THEN pg.monto ELSE 0 END) AS deposito_devuelto
FROM reserva r
LEFT JOIN pago pg ON pg.id_reserva = r.id_reserva
GROUP BY r.folio, r.total_estimado
ORDER BY r.folio;