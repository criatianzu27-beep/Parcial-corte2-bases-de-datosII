USE parcial2_biblioteca;

DROP FUNCTION IF EXISTS fn_calcular_multa;
DELIMITER //

CREATE FUNCTION fn_calcular_multa(
    p_fecha_limite DATE,
    p_fecha_referencia DATE
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_dias INT DEFAULT 0;
    DECLARE v_multa DECIMAL(10,2) DEFAULT 0.00;

    IF p_fecha_limite IS NULL OR p_fecha_referencia IS NULL
       OR p_fecha_referencia <= p_fecha_limite THEN
        RETURN 0.00;
    END IF;

    SET v_dias = DATEDIFF(p_fecha_referencia, p_fecha_limite);
    SET v_multa = v_dias * 1500.00;

    IF v_multa > 30000.00 THEN
        SET v_multa = 30000.00;
    END IF;

    RETURN v_multa;
END //

DELIMITER ;

-- Prueba rápida de la función:
SELECT fn_calcular_multa(CURDATE(), CURDATE()) AS sin_retraso,
       fn_calcular_multa(CURDATE() - INTERVAL 1 DAY, CURDATE()) AS retraso_1_dia,
       fn_calcular_multa(CURDATE() - INTERVAL 25 DAY, CURDATE()) AS multa_tope;

-- Consulta solicitada: préstamos activos con retraso y multa estimada.
SELECT p.id,
       s.nombre AS socio,
       l.titulo AS libro,
       p.fecha_limite,
       GREATEST(DATEDIFF(CURDATE(), p.fecha_limite), 0) AS dias_retraso,
       fn_calcular_multa(p.fecha_limite, CURDATE()) AS multa_estimada
FROM prestamos AS p
JOIN socios AS s ON s.id = p.socio_id
JOIN libros AS l ON l.id = p.libro_id
WHERE p.estado = 'ACTIVO'
ORDER BY p.id;
