-- ////// PRACTICA 4: TRIGGER //////////

-- TAREA: Implementa un trigger llamado trg_send_stock_alert_on_low_stock del que se
-- dispare después de que se actualice el stock de un producto en la tabla Productos.

-- 1. Primero, crea una tabla Alertas_Stock con campos como id_alerta, id_producto, sku,
-- stock_actual, umbral_minimo y fecha_alerta.


	CREATE TABLE alertas_stock (
		id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		id_producto INT NOT NULL,
		stockACT INT,
		fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	
-- 2. El trigger debe verificar si el nuevo valor de stock (después de la actualización) es
-- menor o igual a 10 (este será nuestro umbral mínimo por defecto).

	CREATE TRIGGER mandar_alerta1
	AFTER UPDATE ON productos
	FOR EACH ROW
	BEGIN
		
		IF NEW.stock <= 10 THEN 
			INSERT INTO alertas_stock (stockACT, id_producto)
	    	VALUES (NEW.stock, NEW.id_producto);
		END IF;
	END;
		
DROP TRIGGER mandar_alerta1
		
UPDATE productos 
SET stock = 9
WHERE id_producto = 1;