# Segundo parcial - Bases de Datos II

## Descripción
Solución del parcial sobre la Biblioteca Municipal de Cartago, desarrollada en MariaDB. Incluye una función para calcular multas, procedimientos para registrar préstamos y devoluciones, triggers de inventario y auditoría, vistas con protección de datos personales, y roles y usuarios con privilegios diferenciados.

## Requisitos
- Entorno Docker del curso con el contenedor `bbdd_mariadb`.
- Acceso a MariaDB con un usuario administrador (`root`).
- Script original `parcial2_base.sql` entregado por el docente.

## Orden de ejecución
1. Ejecutar el archivo original `parcial2_base.sql` como `root`. No modificarlo.
2. Ejecutar `01_funcion.sql`.
3. Ejecutar `02_procedimientos.sql`.
4. Ejecutar `03_triggers.sql`.
5. Ejecutar `04_vistas.sql`.
6. Ejecutar `05_seguridad.sql`.
7. Ejecutar las pruebas de `06_pruebas.sql`, siguiendo los comentarios y realizando las pruebas que generan errores una por una.

## Objetos creados
- `fn_calcular_multa`: calcula $1.500 por día de retraso, con multa máxima de $30.000.
- `sp_registrar_prestamo`: valida socio, multas pendientes, cantidad de préstamos, existencia del libro y disponibilidad; crea el préstamo y descuenta un ejemplar.
- `sp_registrar_devolucion`: valida el préstamo, calcula la multa y registra la devolución.
- `trg_prestamo_devuelto`: aumenta los ejemplares disponibles al cambiar un préstamo de ACTIVO a DEVUELTO.
- `trg_auditar_socios`: registra los cambios de email, teléfono y estado de los socios.
- `vw_socios_publico`: muestra datos públicos y enmascara documento y teléfono; no incluye email.
- `vw_prestamos_activos`: presenta préstamos activos, retraso y multa estimada.
- Roles: `rol_lector`, `rol_bibliotecario` y `rol_admin_biblioteca`, con los privilegios indicados en el enunciado.

## Usuarios de prueba
Se crean `u_lector`, `u_bibliotecario` y `u_admin_biblio`, con host `%`. Las contraseñas de ejemplo están en `05_seguridad.sql`; deben manejarse de acuerdo con las indicaciones del docente. El bibliotecario tiene vencimiento de contraseña a 60 días y máximo de 3 conexiones simultáneas.

## Pruebas y evidencias
El archivo `06_pruebas.sql` contiene consultas para verificar las multas, las operaciones y las vistas, además de ejemplos comentados para probar validaciones y permisos. Guardar capturas legibles de las pruebas en la carpeta `capturas/` y agregarlas al repositorio.

## Importante
Ejecutar los scripts en el orden indicado y comprobar cada resultado. Las llamadas que se espera que produzcan un error están comentadas para que puedan ejecutarse individualmente. Verificar la sintaxis de roles, contraseña y límites de conexión con la versión de MariaDB usada en el curso.
