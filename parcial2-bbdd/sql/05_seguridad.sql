USE parcial2_biblioteca;

-- Contraseñas de ejemplo para la práctica: cámbialas si el docente indica otra política.
-- Cumplen: mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial.

CREATE ROLE IF NOT EXISTS rol_lector;
CREATE ROLE IF NOT EXISTS rol_bibliotecario;
CREATE ROLE IF NOT EXISTS rol_admin_biblioteca;

-- Lector: acceso únicamente a las dos vistas públicas.
GRANT SELECT ON parcial2_biblioteca.vw_socios_publico TO rol_lector;
GRANT SELECT ON parcial2_biblioteca.vw_prestamos_activos TO rol_lector;

-- Bibliotecario hereda el rol lector y puede ejecutar la función y procedimientos.
GRANT rol_lector TO rol_bibliotecario;
GRANT EXECUTE ON PROCEDURE parcial2_biblioteca.sp_registrar_prestamo TO rol_bibliotecario;
GRANT EXECUTE ON PROCEDURE parcial2_biblioteca.sp_registrar_devolucion TO rol_bibliotecario;
GRANT EXECUTE ON FUNCTION parcial2_biblioteca.fn_calcular_multa TO rol_bibliotecario;

-- Administrador: CRUD sobre las tablas operativas y solo lectura de auditoría.
GRANT SELECT, INSERT, UPDATE, DELETE ON parcial2_biblioteca.socios TO rol_admin_biblioteca;
GRANT SELECT, INSERT, UPDATE, DELETE ON parcial2_biblioteca.libros TO rol_admin_biblioteca;
GRANT SELECT, INSERT, UPDATE, DELETE ON parcial2_biblioteca.prestamos TO rol_admin_biblioteca;
GRANT SELECT ON parcial2_biblioteca.auditoria_socios TO rol_admin_biblioteca;

CREATE USER IF NOT EXISTS 'u_lector'@'%' IDENTIFIED BY 'Lector2026!';
CREATE USER IF NOT EXISTS 'u_bibliotecario'@'%' IDENTIFIED BY 'Biblio2026!';
CREATE USER IF NOT EXISTS 'u_admin_biblio'@'%' IDENTIFIED BY 'AdminBiblio2026!';

GRANT rol_lector TO 'u_lector'@'%';
GRANT rol_bibliotecario TO 'u_bibliotecario'@'%';
GRANT rol_admin_biblioteca TO 'u_admin_biblio'@'%';

SET DEFAULT ROLE rol_lector TO 'u_lector'@'%';
SET DEFAULT ROLE rol_bibliotecario TO 'u_bibliotecario'@'%';
SET DEFAULT ROLE rol_admin_biblioteca TO 'u_admin_biblio'@'%';

-- Requisitos adicionales del usuario bibliotecario.
ALTER USER 'u_bibliotecario'@'%' PASSWORD EXPIRE INTERVAL 60 DAY;
ALTER USER 'u_bibliotecario'@'%' WITH MAX_USER_CONNECTIONS 3;

SHOW GRANTS FOR 'u_lector'@'%';
SHOW GRANTS FOR 'u_bibliotecario'@'%';
SHOW GRANTS FOR 'u_admin_biblio'@'%';
