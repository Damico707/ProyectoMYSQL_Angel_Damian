-- /////////// PRACTICA 3 ///////////

-- TAREA: Crea un procedimiento almacenado llamado sp_AjustarNivelStock que acepte
-- como parámetros id_producto, cantidad_ajuste (puede ser positiva para adiciones o
-- negativa para sustracciones) y motivo.

-- 1. El procedimiento debe validar que el stock resultante no sea negativo. Si el ajuste
-- provoca un stock negativo, debe lanzar un error (usando SIGNAL SQLSTATE) y
-- detener la ejecución.

-- 2. tambien cumple el 2, actualizar en productos

CREATE PROCEDURE sp_ajustarnivelstock1 (p_id_producto INT, cantidad_ajuste INT)
BEGIN
	DECLARE v_stock_antiguo INT;
	DECLARE suma_stock INT;
	
	SELECT p.stock
	INTO v_stock_antiguo
	FROM productos p 
	WHERE p.id_producto = p_id_producto;
	
	SET suma_stock =  v_stock_antiguo + cantidad_ajuste;  -- se hace con suma asi el usuario sea el que el de la resta poniendo negativos o positivos
	
	IF suma_stock < 0 THEN 
		signal sqlstate '45000'
		set message_text = 'El stock no puede ser negativo';
	ELSE
		UPDATE productos
		SET stock = suma_stock
		WHERE id_producto = p_id_producto;
	END IF;
END;

CALL sp_ajustarnivelstock1 (1, 11);

DROP PROCEDURE sp_ajustarnivelstock1;

-- 3. Debe insertar un registro en una tabla Auditoria_Stock (que también debes crear)
-- con los campos: id_auditoria, id_producto, cantidad_ajuste, stock_anterior,
-- stock_nuevo, motivo y fecha.
-- cumple el 4, ejecutarse dentro de toda una transaccion


CREATE PROCEDURE sp_ajustarnivelstock3 (p_id_producto INT, cantidad_ajuste INT)
BEGIN
	DECLARE v_stock_antiguo INT;
	DECLARE suma_stock INT;
	
	SELECT p.stock
	INTO v_stock_antiguo
	FROM productos p 
	WHERE p.id_producto = p_id_producto;
	
	SET suma_stock =  v_stock_antiguo + cantidad_ajuste;  -- se hace con suma asi el usuario sea el que el de la resta poniendo negativos o positivos
	
	IF suma_stock < 0 THEN 
		signal sqlstate '45000'
		set message_text = 'El stock no puede ser negativo';
	ELSE
		UPDATE productos
		SET stock = suma_stock
		WHERE id_producto = p_id_producto;
	
	INSERT INTO alertas_stock ( id_producto, stockACT)
	    VALUES (p_id_producto, suma_stock);
	END IF;
END;

CALL sp_ajustarnivelstock3 (1, 11);

DROP PROCEDURE sp_ajustarnivelstock1;