-- ===================================
-- ROLES Y PERMISOS
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

-- 1. Crear rol administrador con todo privilegio

	CREATE ROLE administrador;
	
	GRANT ALL PRIVILEGES
	ON proyectoSQL.*
	TO administrador;
	
-- 2. Crear rol Gerente de marketing con acceso solo de lectura a ventas y clientes
	
	CREATE ROLE gerente_marketing;
	
	GRANT SELECT
	ON proyectoSQL.ventas
	TO gerente_marketing;
	
	GRANT SELECT
	ON proyectoSQL.clientes
	TO gerente_marketing;

	-- 3. Crear rol analista de datos con acceso solo a lectura de todas las tablas, excepto auditoria
	
	CREATE ROLE analista_datos;
	
	GRANT SELECT
	ON proyectoSQL.ventas
	TO analista_datos;
	
	GRANT SELECT
	ON proyectoSQL.categorias
	TO analista_datos;
	
	GRANT SELECT
	ON proyectoSQL.clientes
	TO analista_datos;
	
	GRANT SELECT
	ON proyectoSQL.detalle_ventas
	TO analista_datos;
	
	GRANT SELECT
	ON proyectoSQL.productos
	TO analista_datos;
	
	GRANT SELECT
	ON proyectoSQL.proveedores
	TO analista_datos;
	
-- 4. Crear rol del empleado que solo pueda modificar la tabla productos (stock y ubicacion)
	
	CREATE ROLE empleado_inventario;
	
	GRANT SELECT 
	ON proyectoSQL.productos
	TO empleado_inventario
	
	GRANT UPDATE (stock), INSERT, UPDATE, DELETE, CREATE
	ON proyectoSQL.productos
	TO empleado_inventario;
	
-- 5. Crear el Rol auditor financiero, solo acceso a lectura de ventas, productos y logs de precios
	
	CREATE ROLE auditor_financiero;
	
	GRANT SELECT
	ON proyectoSQL.ventas
	TO auditor_financiero;
	
	GRANT SELECT 
	ON proyectoSQL.productos
	TO auditor_financiero;
	
-- rol 6: Crear el rol Auditor_Financiero con acceso de solo lectura a ventas, productos y logs de precios.
drop role if exists Auditor_Financiero;
create role if not exists Auditor_Financiero;

grant select 
on proyectoSQL.ventas 
to Auditor_Financiero;

grant select 
on proyectoSQL.productos 
to Auditor_Financiero;

grant select 
on proyectoSQL.logs_precios 
to Auditor_Financiero;

-- rol 7: Crear un usuario admin_user y asignarle el rol de administrador.
drop role if exists admin_user;
create role admin_user;

grant all privileges
on proyectoSQL.*
to admin_user;

-- rol 8: Crear un usuario marketing_user y asignarle el rol de marketing. 
drop role if exists marketing_user;
create role marketing_user;

grant select
on proyectoSQL.productos
to marketing_user;

grant select
on proyectoSQL.categorias
to marketing_user;

grant select
on proyectoSQL.ventas
to marketing_user;

grant select
on proyectoSQL.detalle_ventas
to marketing_user;

grant select
on proyectoSQL.clientes
to marketing_user;

-- rol 9: Crear un usuario inventory_user y asignarle el rol de inventario.
drop role if exists inventory_user;
create role inventory_user;

grant select 
on proyectoSQL.productos
to inventory_user;

grant update  
on proyectoSQL.productos
to inventory_user;

grant insert
on proyectoSQL.productos
to inventory_user;

grant select 
on proyectoSQL.categorias
to inventory_user;

grant select 
on proyectoSQL.proveedores
to inventory_user;

-- rol 10: Crear un usuario support_user y asignarle el rol de atención al cliente.
drop role if exists support_user;
create role support_user;

grant select 
on proyectoSQL.clientes
to support_user;

grant select 
on proyectoSQL.ventas
to support_user;

grant select 
on proyectoSQL.detalle_ventas
to support_user;

grant select 
on proyectoSQL.productos
to support_user;
	
-- 11. Impedir que el analista de datos pueda ejecutar comandos DELETE O TRUNCATE
	
	REVOKE DELETE 
	ON proyectoSQL.*
	FROM analista_datos;
	
	REVOKE DROP
	ON proyectoSQL.*
	FROM analista_datos;
	
-- 12. otorgar al rol gerente de marketing permiso para ejecutar procedimientos almacenados de reportes de marketing
	
	GRANT EXECUTE   -- execute permite hacer procedimientos y funciones no como update que altera tablas
	ON PROCEDURE proyectoSQL.reporte_ventas_mensuales  -- pues no existe esa tabla pero es un ejemplo
	TO gerente_marketing;

-- 13. Crear una vista que oculte informacion sensilble al dar acceso a ella al rol atencion al cliente
	CREATE VIEW vista_clientes_atencion AS
	SELECT 
	    id_cliente,
	    nombre,
	    apellido,
	    CONCAT(
	        LEFT(email, 3),
	        '***@',
	        SUBSTRING_INDEX(email, '@', -1)
	    ) AS email_oculto,
	    direccion_envio,
	    fecha_registro
	FROM clientes;

CREATE ROLE atencion_cliente;

GRANT SELECT
ON proyectoSQL.vista_clientes_atencion
TO atencion_cliente;

-- 14.Revocar el permiso de UPDATE sobre la columna precio de la tabla productos al rol Empleado_Inventario.
	
	REVOKE UPDATE (precio)
	ON proyectoSQL.productos
	FROM empleado_inventario;

-- 15. Implementar una política de contraseñas seguras para todos los usuarios.
	
INSTALL COMPONENT 'file://component_validate_password';

SET GLOBAL validate_password.policy = STRONG;
SET GLOBAL validate_password.length = 12;
SET GLOBAL validate_password.mixed_case_count = 1;
SET GLOBAL validate_password.number_count = 1;
SET GLOBAL validate_password.special_char_count = 1;
	
-- rol 16: Asegurar que el usuario root no pueda ser usado desde conexiones remotas.
SELECT user, host
FROM mysql.user
WHERE user = 'root';
-- el usuario 'root' ya se encuentra en localhost

-- rol 17: Crear un rol Visitante que solo pueda ver la tabla productos.
drop role if exists guest;
create role guest;

grant select 
on proyectoSQL.productos
to guest;

drop user if exists 'visitante'@'localhost';

create user 'visitante'@'localhost'
identified by 'visitorfrog';

grant guest 
to 'visitante'@'localhost';
set default role guest
to 'visitante'@'localhost';

-- rol 18: 
drop role if exists analista_datos; 
create role analista_datos;

grant select
on proyectoSQL.*
to analista_datos;

drop user if exists 'ana_alista_datos'@'localhost';
create user 'ana_alista_datos'@'localhost'
identified by 'anaestalista';

alter user 'ana_alista_datos'@'localhost'
with max_queries_per_hour 500;


-- rol 19: Asegurar que los usuarios solo puedan ver las ventas de la sucursal a la que pertenecen (requiere añadir id_sucursal).
create view vw_ventas_medellin AS 
select *
from ventas v
where id_sucursal = 1;

create view vw_ventas_bogota AS 
select *
from ventas v
where id_sucursal = 2;

create view vw_ventas_cartagena AS 
select *
from ventas v
where id_sucursal = 3;

create view vw_ventas_bucaramanga AS 
select *
from ventas v
where id_sucursal = 4;

drop user if exists 'ventas_bogota'@'localhost';
create user 'ventas_bogota'@'localhost'
identified by 'ventasbogota2026';

drop user if exists 'ventas_medellin'@'localhost';
create user 'ventas_medellin'@'localhost'
identified by 'ventasmedellin2026';

drop user if exists 'ventas_bga'@'localhost';
create user 'ventas_bga'@'localhost'
identified by 'ventasbga2026';

drop user if exists 'ventas_cartagena'@'localhost';
create user 'ventas_cartagena'@'localhost'
identified by 'ventascartagena2026';

grant update, insert 
on proyectoSQL.ventas
to 'ventas_bogota'@'localhost';

grant update, insert 
on proyectoSQL.ventas
to 'ventas_medellin'@'localhost';

grant update, insert 
on proyectoSQL.ventas
to 'ventas_bga'@'localhost';

grant update, insert 
on proyectoSQL.ventas
to 'ventas_cartagena'@'localhost';


