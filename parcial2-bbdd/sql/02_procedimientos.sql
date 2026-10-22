USE parcial2_biblioteca;

DROP PROCEDURE IF EXISTS sp_registrar_prestamo;
DROP PROCEDURE IF EXISTS sp_registrar_devolucion;

DELIMITER //

CREATE PROCEDURE sp_registrar_prestamo(
    IN p_documento VARCHAR(15),
    IN p_isbn VARCHAR(20),
    OUT p_id_prestamo INT
)
BEGIN
    DECLARE v_socio_id INT DEFAULT NULL;
    DECLARE v_estado VARCHAR(20) DEFAULT NULL;
    DECLARE v_pendientes INT DEFAULT 0;
    DECLARE v_activos INT DEFAULT 0;
    DECLARE v_libro_id INT DEFAULT NULL;
    DECLARE v_disponibles INT DEFAULT NULL;

    SET p_id_prestamo = NULL;

    -- Las validaciones se realizan en el orden indicado en el enunciado.
    SELECT id, estado
      INTO v_socio_id, v_estado
      FROM socios
     WHERE documento = p_documento
     LIMIT 1;

    IF v_socio_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio no existe';
    END IF;

    IF v_estado = 'SUSPENDIDO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio está suspendido';
    END IF;

    SELECT COUNT(*)
      INTO v_pendientes
      FROM prestamos
     WHERE socio_id = v_socio_id
       AND multa > 0
       AND multa_pagada = 0;

    IF v_pendientes > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio tiene multas pendientes';
    END IF;

    SELECT COUNT(*)
      INTO v_activos
      FROM prestamos
     WHERE socio_id = v_socio_id
       AND estado = 'ACTIVO';

    IF v_activos >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio ya tiene 3 préstamos activos';
    END IF;

    SELECT id, ejemplares_disponibles
      INTO v_libro_id, v_disponibles
      FROM libros
     WHERE isbn = p_isbn
     LIMIT 1;

    IF v_libro_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro no existe';
    END IF;

    IF v_disponibles <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay ejemplares disponibles';
    END IF;

    INSERT INTO prestamos
        (socio_id, libro_id, fecha_prestamo, fecha_limite,
         fecha_devolucion, multa, multa_pagada, estado)
    VALUES
        (v_socio_id, v_libro_id, CURDATE(), CURDATE() + INTERVAL 15 DAY,
         NULL, 0.00, 0, 'ACTIVO');

    SET p_id_prestamo = LAST_INSERT_ID();

    UPDATE libros
       SET ejemplares_disponibles = ejemplares_disponibles - 1
     WHERE id = v_libro_id;
END //

CREATE PROCEDURE sp_registrar_devolucion(
    IN p_prestamo_id INT,
    OUT p_multa DECIMAL(10,2)
)
BEGIN
    DECLARE v_estado VARCHAR(20) DEFAULT NULL;
    DECLARE v_fecha_limite DATE DEFAULT NULL;

    SET p_multa = NULL;

    SELECT estado, fecha_limite
      INTO v_estado, v_fecha_limite
      FROM prestamos
     WHERE id = p_prestamo_id
     LIMIT 1;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo no existe';
    END IF;

    IF v_estado = 'DEVUELTO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo ya fue devuelto';
    END IF;

    SET p_multa = fn_calcular_multa(v_fecha_limite, CURDATE());

    UPDATE prestamos
       SET fecha_devolucion = CURDATE(),
           multa = p_multa,
           estado = 'DEVUELTO'
     WHERE id = p_prestamo_id;
    -- El trigger R5 se encarga de devolver el ejemplar al inventario.
END //

DELIMITER ;
