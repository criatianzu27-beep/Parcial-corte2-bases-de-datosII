USE parcial2_biblioteca;

-- Ejecutar estas pruebas después de crear función, procedimientos, triggers, vistas y roles.
-- Algunas pruebas generan intencionalmente errores SIGNAL; ejecútalas una por una.

-- R2: multa a tiempo, 1 día, 5 días y tope de 25 días.
SELECT fn_calcular_multa(CURDATE(), CURDATE()) AS multa_a_tiempo; -- 0.00
SELECT fn_calcular_multa(CURDATE() - INTERVAL 1 DAY, CURDATE()) AS multa_1_dia; -- 1500.00
SELECT fn_calcular_multa(CURDATE() - INTERVAL 5 DAY, CURDATE()) AS multa_5_dias; -- 7500.00
SELECT fn_calcular_multa(CURDATE() - INTERVAL 25 DAY, CURDATE()) AS multa_25_dias; -- 30000.00

-- R3: prueba exitosa. Documento e ISBN válidos; el préstamo nuevo debe devolver su ID.
SET @nuevo_prestamo = NULL;
CALL sp_registrar_prestamo('1112100001', '978-958-002', @nuevo_prestamo);
SELECT @nuevo_prestamo AS id_prestamo_creado;

-- R3: las siguientes pruebas están diseñadas para generar cada error.
-- Ejecutar por separado, porque cada CALL inválido detiene su propia ejecución.
-- CALL sp_registrar_prestamo('NO-EXISTE', '978-958-002', @id); -- El socio no existe
-- CALL sp_registrar_prestamo('1112100004', '978-958-002', @id); -- El socio está suspendido
-- CALL sp_registrar_prestamo('1112100002', '978-958-002', @id); -- El socio tiene multas pendientes
-- Para probar límite de 3 activos, usar un socio ACTIVO sin multas pendientes que ya tenga 3 activos.
-- CALL sp_registrar_prestamo('DOCUMENTO_DE_PRUEBA', '978-958-002', @id); -- El socio ya tiene 3 préstamos activos
-- CALL sp_registrar_prestamo('1112100001', 'ISBN-INEXISTENTE', @id); -- El libro no existe
-- CALL sp_registrar_prestamo('1112100001', '978-958-004', @id); -- No hay ejemplares disponibles
-- Nota: las validaciones se evalúan en orden. Use datos que superen las anteriores para llegar a cada caso.

-- R4: seleccionar un préstamo ACTIVO para probar devolución.
-- Compruebe primero el ID con: SELECT id, estado FROM prestamos WHERE estado='ACTIVO';
-- SET @multa_devolucion = NULL;
-- CALL sp_registrar_devolucion(ID_ACTIVO, @multa_devolucion);
-- SELECT @multa_devolucion AS multa_devuelta;
-- Repetir con ese mismo ID debe producir: El préstamo ya fue devuelto.
-- CALL sp_registrar_devolucion(ID_ACTIVO, @multa_devolucion);
-- Un ID inexistente debe producir: El préstamo no existe.
-- CALL sp_registrar_devolucion(999999, @multa_devolucion);

-- R5: el trigger de devolución incrementa el inventario; el trigger de auditoría guarda
-- un registro por cada campo cambiado entre email, telefono y estado.
UPDATE socios
   SET email = 'mariana.nuevo@correo.com',
       telefono = '3001112233'
 WHERE documento = '1112100001';
SELECT * FROM auditoria_socios WHERE socio_id = 1 ORDER BY id;

-- R6: vistas.
SELECT * FROM vw_socios_publico;
SELECT * FROM vw_prestamos_activos;

-- Para evidenciar permisos, conectarse por separado como cada usuario.
-- Como u_lector: operación permitida:
-- SELECT * FROM parcial2_biblioteca.vw_socios_publico;
-- Como u_lector: operación denegada esperada:
-- SELECT * FROM parcial2_biblioteca.socios;
-- Como u_bibliotecario: operación permitida:
-- CALL parcial2_biblioteca.sp_registrar_devolucion(ID_ACTIVO, @multa);
-- Como u_bibliotecario: operación denegada esperada:
-- UPDATE parcial2_biblioteca.socios SET telefono='3000000000' WHERE id=1;
-- Como u_admin_biblio: operación permitida:
-- SELECT * FROM parcial2_biblioteca.auditoria_socios;
-- Como u_admin_biblio: operación denegada esperada:
-- INSERT INTO parcial2_biblioteca.auditoria_socios
-- (socio_id,campo,valor_anterior,valor_nuevo,usuario_sesion,usuario_privilegios)
-- VALUES (1,'prueba','a','b',USER(),CURRENT_USER());
