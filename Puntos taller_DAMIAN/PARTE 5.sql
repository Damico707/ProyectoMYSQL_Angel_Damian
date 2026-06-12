-- //////// PRACTICA 5 ///////////
-- Crea un evento programado llamado evt_aggregate_daily_sales_data

CREATE TABLE resumen_ventas_diarias (
    fecha DATE PRIMARY KEY,
    ventas_totales DECIMAL(10,2),
    transacciones_unicas INT,
    unidades_vendidas INT
);

SET GLOBAL event_scheduler = ON;

DELIMITER //

CREATE EVENT ventasdiarias1
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

    INSERT INTO resumen_ventas_diarias
    (fecha, ventas_totales, transacciones_unicas, unidades_vendidas)
    SELECT
        CURDATE(),
        COALESCE(SUM(dv.cantidad * dv.precio_unitario_congelado), 0),
        COUNT(DISTINCT v.id_venta),
        COALESCE(SUM(dv.cantidad), 0)
    FROM ventas v
    JOIN detalle_ventas dv
        ON dv.id_venta = v.id_venta
    WHERE DATE(v.fecha_venta) = CURDATE()
      AND v.estado <> 'cancelado'
    ON DUPLICATE KEY UPDATE
        ventas_totales = VALUES(ventas_totales),
        transacciones_unicas = VALUES(transacciones_unicas),
        unidades_vendidas = VALUES(unidades_vendidas);

END ;

DELIMITER ;


SELECT * 
FROM resumen_ventas_diarias;

INSERT INTO ventas
(id_cliente, fecha_venta, estado, total)
VALUES
(1, NOW(), 'entregado', 545000);

INSERT INTO detalle_ventas
( id_venta, id_producto, cantidad, precio_unitario_congelado)
VALUES
( LAST_INSERT_ID(), 1, 2, 180000),
( LAST_INSERT_ID(), 6, 1, 185000);
 

 -- A lo bien no entendi juasjuasjuas