-- ===================================
-- EVENTOS
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

SHOW VARIABLES LIKE 'event_scheduler';
show events;

SET GLOBAL event_scheduler = ON;

-- 1.  Genera un reporte de ventas semanal.

	CREATE TABLE reporte_ventas_semanal (
	    desde DATE,
	    hasta DATE,
	    cantidad_ventas INT,
	    total_semana DECIMAL(12,2)
	);
	
DELIMITER //

CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN
    INSERT INTO reporte_ventas_semanal
    SELECT
        MIN(DATE(fecha_venta)),
        MAX(DATE(fecha_venta)),
        COUNT(*),
        SUM(total)
    FROM ventas
    WHERE DATE(fecha_venta) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
      AND estado != 'cancelado';
END //

DELIMITER ;
	
	SELECT * FROM reporte_ventas_semanal;
	
-- 2. Borra tablas temporales diariamente.
	
	
	CREATE EVENT evt_cleanup_temp_tables_daily
	ON SCHEDULE EVERY 1 DAY
	DO
	BEGIN
	    DELETE FROM ventas_diarias;
	    DELETE FROM lista_reabastecimiento;
	END;
	
-- 3.  Archiva logs de más de 6 meses en tablas históricas.
	
	CREATE TABLE historial_logs_cambios_precio (
	    id INT,
	    id_producto INT,
	    precio_anterior DECIMAL(10,2),
	    precio_nuevo DECIMAL(10,2),
	    fecha TIMESTAMP
	);
	
	CREATE EVENT evt_archive_old_logs_monthly
	ON SCHEDULE EVERY 1 MONTH
	DO
	BEGIN
	    INSERT INTO historial_logs_cambios_precio
	    SELECT *
	    FROM logs_cambios_precio
	    WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
	
	    DELETE FROM logs_cambios_precio
	    WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
	END;
	    
-- 4. Desactiva códigos de descuento que han expirado.
	    
	CREATE TABLE promociones (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20),
    fecha_expiracion DATE,
    activa BOOLEAN DEFAULT TRUE
	);
	
	
	CREATE EVENT evt_deactivate_expired_promotions_hourly
	ON SCHEDULE EVERY 1 HOUR
	DO
	BEGIN
	    UPDATE promociones
	    SET activa = FALSE
	    WHERE fecha_expiracion < CURDATE();
	END;
	
-- 5. Recalcula el nivel de lealtad de los clientes cada noche.
	    
	ALTER TABLE clientes
	ADD nivel_lealtad VARCHAR(20); 
	
	CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
	ON SCHEDULE EVERY 1 DAY
	DO
	BEGIN
	    UPDATE clientes c
	    SET nivel_lealtad =
	    (
	        SELECT
	            CASE
	                WHEN COUNT(*) >= 5 THEN 'Oro'
	                WHEN COUNT(*) >= 3 THEN 'Plata'
	                ELSE 'Bronce'
	            END
	        FROM ventas v
	        WHERE v.id_cliente = c.id_cliente
	    );
	END;
	
	-- 6. evt_generate_reorder_list_daily: Crea una lista de productos que necesitan ser reabastecidos.
delimiter //
create event evt_generate_reorder_list_daily
on schedule every 1 day
do 
begin
	truncate table lista_reabastecimiento;
	
	insert into lista_reabastecimiento (id_producto, nombre, stock_actual)
	select id_producto, nombre, stock
	from productos 
	where stock < 8;
end //
delimiter ;


-- 7. evt_rebuild_indexes_weekly: Reconstruye los índices de las tablas más usadas para optimizar el rendimiento.
delimiter //
create event evt_rebuild_indexes_weakly
on schedule every 1 week
do
begin
	analyze table productos;
	analyze table ventas;
	analyze table detalle_ventas;
	analyze table clientes;
	analyze table categorias;
	analyze table proveedores;

end //
delimiter ;

-- 8. evt_suspend_inactive_accounts_quarterly: Desactiva cuentas de clientes sin actividad en más de un año.
delimiter //
create event evt_suspend_inactive_accounts_quarterly
on schedule every 3 month
do 
begin
	update clientes
	set estado = 'inactivo'
	where ultimo_pedido is null 
		or ultimo_pedido < now() - interval 1 year;
end //
delimiter ;

-- 9. evt_aggregate_daily_sales_data: Agrega los datos de ventas del día en una tabla de resumen para acelerar reportes.
delimiter //
create event evt_aggregate_daily_sales_data
on schedule every 1 day
do 
begin
	truncate table ventas_diarias;

	insert into ventas_diarias (id_venta, id_producto, id_cliente, fecha_venta)
	select dv.id_venta, 
		   dv.id_producto, 
		   v.id_cliente, 
		   v.fecha_venta
	from detalle_ventas dv
	join ventas v
		on dv.id_venta = v.id_venta
	where date(v.fecha_venta) = curdate();
end //
delimiter ;

-- 10. evt_check_data_consistency_nightly: Busca inconsistencias en los datos (ej. ventas sin detalles).
delimiter //
create event evt_check_data_consistency_nightly
on schedule every 1 day
do
begin
	truncate table inconsistencias;
	insert into inconsistencias (tipo, descripcion)
	select 
		'venta sin detalles',
		concat('la venta ', v.id_venta, ' no tiene detalles asociados')
	from ventas v
	left join detalle_ventas dv 
		on v.id_venta = dv.id_venta
	where dv.id_venta is null;
end //
delimiter ; 

-- 11.  Genera una lista de clientes que cumplen años para enviarles un cupón.

	CREATE TABLE cumpleanos_clientes (
    id_cliente INT,
    nombre VARCHAR(100),
    email VARCHAR(100),
    fecha_generacion DATE
	);


CREATE EVENT evt_send_birthday_greetings_daily
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    INSERT INTO cumpleanos_clientes
    SELECT
        id_cliente,
        nombre,
        email,
        CURDATE()
    FROM clientes
    WHERE DAY(fecha_nacimiento) = DAY(CURDATE())
      AND MONTH(fecha_nacimiento) = MONTH(CURDATE());
END;

-- 12. Actualiza una tabla con el ranking de los productos más populares.

	CREATE TABLE ranking_productos (
    id_producto INT,
    nombre VARCHAR(100),
    unidades_vendidas INT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	
CREATE EVENT evt_update_product_rankings_hourly
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    DELETE FROM ranking_productos;

    INSERT INTO ranking_productos
    SELECT
        p.id_producto,
        p.nombre,
        SUM(dv.cantidad)
    FROM productos p
    INNER JOIN detalle_ventas dv ON p.id_producto = dv.id_producto
    GROUP BY p.id_producto, p.nombre
    ORDER BY SUM(dv.cantidad) DESC;
END;

-- 13. Realiza un backup lógico de las tablas más importantes cada noche.

CREATE TABLE backup_clientes AS SELECT * FROM clientes;
CREATE TABLE backup_productos AS SELECT * FROM productos;
CREATE TABLE backup_ventas AS SELECT * FROM ventas;


CREATE EVENT evt_backup_critical_tables_daily
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    TRUNCATE TABLE backup_clientes;
    TRUNCATE TABLE backup_productos;
    TRUNCATE TABLE backup_ventas;

    INSERT INTO backup_clientes SELECT * FROM clientes;
    INSERT INTO backup_productos SELECT * FROM productos;
    INSERT INTO backup_ventas SELECT * FROM ventas;
END;

-- 14. evt_clear_abandoned_carts_daily: Vacía los carritos de compra abandonados hace más de 72 horas.

	CREATE TABLE carritos (
    id_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha_creacion TIMESTAMP,
    estado VARCHAR(50)
	);
	
	CREATE EVENT evt_clear_abandoned_carts_daily
	ON SCHEDULE EVERY 1 DAY
	DO
	BEGIN
	    DELETE FROM carritos
	    WHERE estado = 'abandonado'
	      AND fecha_creacion < DATE_SUB(NOW(), INTERVAL 72 HOUR);
	END;
	
-- 15. Calcula los KPIs (Key Performance Indicators) del mes y los guarda en una tabla.
	
CREATE TABLE kpis_mensuales (
    mes INT,
    anio INT,
    total_ventas DECIMAL(12,2),
    cantidad_ventas INT,
    promedio_venta DECIMAL(12,2),
	fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	
	CREATE EVENT evt_calculate_monthly_kpis
	ON SCHEDULE EVERY 1 MONTH
	DO
	BEGIN
	    INSERT INTO kpis_mensuales
	    SELECT
	        MONTH(fecha_venta),
	        YEAR(fecha_venta),
	        SUM(total),
	        COUNT(*),
	        AVG(total)
	    FROM ventas
	    WHERE MONTH(fecha_venta) = MONTH(CURDATE())
	      AND YEAR(fecha_venta) = YEAR(CURDATE())
	      AND estado <> 'cancelado'
	    GROUP BY MONTH(fecha_venta), YEAR(fecha_venta);
	END;

-- 16. evt_refresh_materialized_views_nightly: Actualiza las vistas materializadas (si se usan).
delimiter //
create event evt_refresh_materialized_views_nightly
on schedule every 1 day
do
begin 
	truncate table mv_ventas_por_categoria;

	insert into mv_ventas_por_categoria (categoria, total_ventas)
	select c.nombre,
		   sum(dv.cantidad * dv.precio_unitario_congelado)
	from detalle_ventas dv
	join productos p
        ON dv.id_producto = p.id_producto
    join categorias c
        on p.categoria = c.id_categoria
    group by c.id_categoria;
end //
delimiter ;

-- 17. evt_log_database_size_weekly: Registra el tamaño de la base de datos para monitorear su crecimiento.
delimiter //
create event evt_log_database_size_weekly
on schedule every 1 week
do
begin
	insert into log_tamano_db ( tamaño_db)
	select round (sum(data_length + index_length) / 1024 / 1024, 2)
	from information_schema.tables
	where table_schema = 'proyectoSQL';
end //
delimiter ;

-- 18. evt_detect_fraudulent_activity_hourly: Busca patrones de actividad sospechosa (ej. múltiples pedidos fallidos).
delimiter //
create event evt_detect_fraudulent_activity_hourly
on schedule every 1 hour
do 
begin
	truncate table actividad_sospechosa;
	insert into actividad_sospechosa (id_cliente, nombre, cantidad_cancelados)
	select v.id_cliente,
		   concat(c.nombre, ' ', c.apellido) as  nombre,
		   count(*)
	from ventas v 
	join clientes c 
		on v.id_cliente = c.id_cliente
	where v.estado = 'cancelado'
		and v.fecha_venta >= now() - interval 1 hour
	group by v.id_cliente
	having count(*) >= 3;
end // 
delimiter ;

-- 19. evt_generate_supplier_performance_report_monthly: Crea un reporte mensual sobre el rendimiento de los proveedores.
delimiter //
create event evt_generate_supplier_performance_report_monthly
on schedule every 1 month
do
begin
	insert into reporte_proveedores (id_proveedor, proveedor, total_ventas, unidades_vendidas, pedidos_participados)
	
	select p.id_proveedor,
		   p.nombre,
		   sum(dv.cantidad * dv.precio_unitario_congelado) as total_ventas,
		   count(distinct v.id_venta) as pedidos_participados,
		   curdate()
	from proveedores p
	join productos pr
		on p.id_proveedor = pr.proveedor
	join detalle_ventas dv
		on pr.id_producto = dv.id_producto
	join ventas v
		on dv.id_venta = v.id_venta
	where v.estado = 'entregado'
	group by p.id_proveedor, p.nombre;
end //
delimiter ;

-- 20. evt_purge_soft_deleted_records_weekly: Elimina permanentemente los registros marcados para borrado hace más de 30 días.

delimiter //
create event if not exists evt_purge_soft_deleted_records_weekly
on schedule every 1 week
do
begin
	delete from productos
	where eliminado = true
		and fecha_eliminacion < now() - interval 30 day;
end //
delimiter ;

