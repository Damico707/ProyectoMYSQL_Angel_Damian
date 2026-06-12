-- ///////////// PRACTICA 2 //////////////
-- TAREA: Crea una función SQL llamada fn_DeterminarEstadoLealtad que reciba un
-- id_cliente como parámetro de entrada.


-- 1. La función debe calcular el gasto total histórico del cliente sumando los totales de
-- todas sus ventas.

CREATE FUNCTION determinarEstadoLealtad (c_id_cliente INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE estado VARCHAR(50);
	DECLARE totalventas INT;
	
	SELECT COUNT(v.id_venta) 
	INTO totalventas
	FROM ventas v
	WHERE v.id_cliente = c_id_cliente;
	
	
	RETURN totalventas;
END;

DROP FUNCTION  determinarEstadoLealtad

SELECT determinarEstadoLealtad(6);

SELECT asignar_lealtad(6);

-- 2. Basándose en el gasto total, debe devolver un VARCHAR con el nivel de lealtad: •
-- "Bronce" si el gasto es menor a 500. • "Plata" si el gasto está entre 500 y 2000. •
-- "Oro" si el gasto es mayor a 2000

CREATE FUNCTION asignar_lealtad2 (c_id_cliente INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE totalgastado DECIMAL(10,2);
	DECLARE estado VARCHAR(50);
	
	SELECT  SUM(dv.cantidad * dv.precio_unitario_congelado  ) as totalventa
	INTO  totalgastado
	FROM ventas v
	JOIN detalle_ventas dv ON dv.id_venta = v.id_venta 
	WHERE v.id_cliente = c_id_cliente;
	
	IF totalgastado < 500
		THEN SET estado = 'bronce';
	
	ELSEIF  totalgastado < 2000 
		THEN SET estado = 'Plata';
	
	ELSEIF totalgastado > 2000
		THEN SET  estado = 'Oro';
	
	END IF;
	
	RETURN estado;
END;

DROP FUNCTION asignar_lealtad2;

SELECT asignar_lealtad2(6);

-- 3. Si el cliente no tiene compras registradas, debe devolver "Nuevo".

CREATE FUNCTION asignar_lealtad3 (c_id_cliente INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE totalgastado DECIMAL(10,2);
	DECLARE estado VARCHAR(50);
	
	SELECT  SUM(dv.cantidad * dv.precio_unitario_congelado  ) as totalventa
	INTO  totalgastado
	FROM ventas v
	JOIN detalle_ventas dv ON dv.id_venta = v.id_venta 
	WHERE v.id_cliente = c_id_cliente;
	
	IF totalgastado IS NULL THEN		
		SET estado= 'nuevo';

	ELSEIF totalgastado < 500
		THEN SET estado = 'bronce';
	
	ELSEIF  totalgastado < 2000 
		THEN SET estado = 'Plata';
	
	ELSEIF totalgastado > 2000
		THEN SET  estado = 'Oro';
	END IF;
	
	RETURN estado;
END;

SELECT asignar_lealtad3(6);