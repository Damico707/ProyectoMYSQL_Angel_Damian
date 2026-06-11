-- ===================================
-- FUNCIONES
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

-- 1. Calcular el monto total de una venta especifica

CREATE FUNCTION fn_CalcularTotalVenta(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT SUM(cantidad * precio_unitario_congelado)
    INTO v_total
    FROM detalle_ventas
    WHERE id_venta = p_id_venta;

    RETURN v_total;
END 

SELECT fn_CalcularTotalVenta(1);

-- 2.  Validar si hay stock suficiente pra un producto

CREATE FUNCTION verificar_stock (p_id_producto INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE v_stock_restante INT;
	
	SELECT p.stock 
	INTO v_stock_restante
	FROM productos p 
	WHERE p.id_producto = p_id_producto;
	
	IF v_stock_restante > 0 THEN
		RETURN v_stock_restante;
	ELSE
		RETURN 'El producto esta sin stock';
	END IF;
END;


SELECT verificar_stock(1);

-- 3. Devolver el precio actual de un producto

CREATE FUNCTION obtener_precio (p_id_producto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE total DECIMAL(10,2);
		
	SELECT p.precio
	INTO total
	FROM productos p 
	WHERE p.id_producto = p_id_producto;
	
	RETURN total;
	
END;

SELECT obtener_precio(1);

-- 4. Calcular la edad de un cliente 

CREATE FUNCTION calcular_edad (c_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
	
	DECLARE fechaN INT;
	DECLARE id_cliente INT;
	
	SELECT  YEAR(c.fecha_nacimiento)
	INTO fechaN
	FROM clientes c
	WHERE c.id_cliente = c_id_cliente;
	
	RETURN YEAR(CURRENT_TIMESTAMP()) - fechaN;
END;

SELECT calcular_edad(1);

-- 5. Devuelve el nombre y apellido de un cliente

CREATE FUNCTION  formatearNombre (c_id_cliente INT)
RETURNS VARCHAR(150)
DETERMINISTIC
BEGIN
	
	DECLARE nombreCompleto VARCHAR(150);
	
	SELECT CONCAT(c.nombre ,' ', c.apellido )
	INTO nombreCompleto
	FROM clientes c
	WHERE c.id_cliente = c_id_cliente;
	
	RETURN nombreCompleto;
END;

SELECT formatearNombre (6);

-- 6: fn_EsClienteNuevo: Devuelve VERDADERO si un cliente realizó su primera compra en los últimos 30 días.

drop function if exists fn_EsClientenuevo;
DELIMITER //
CREATE FUNCTION fn_EsClienteNuevo(p_id_cliente INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE fecha_primera_compra DATE;
    SELECT MIN(DATE(fecha_venta))
    INTO fecha_primera_compra
    FROM ventas
    WHERE id_cliente = p_id_cliente
      AND estado NOT IN ('cancelado', 'pendiente_pago');
    IF fecha_primera_compra IS NULL THEN
        RETURN FALSE;
    END IF;
    IF DATEDIFF(NOW(), fecha_primera_compra) <= 30 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER 

-- prueba
SELECT 
    id_cliente,
    CONCAT(nombre, ' ', apellido) AS cliente,
 	fn_EsClienteNuevo(id_cliente) AS es_nuevo
FROM clientes;

-- 7: fn_CalcularCostoEnvio: Calcula el costo de envío basado en el peso total de los productos de una venta.
DELIMITER //
CREATE FUNCTION fn_CalcularCostoEnvio(p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_unidades INT;
    DECLARE peso_por_unidad DECIMAL(5,2);
    DECLARE costo_por_kg DECIMAL(10,2);
    DECLARE peso_total DECIMAL(10,2);
    DECLARE costo_envio DECIMAL(10,2);
    SET peso_por_unidad = 0.3;   
	SET costo_por_kg   = 5000;   
    SELECT SUM(cantidad)
    INTO total_unidades
    FROM detalle_ventas
    WHERE id_venta = p_id_venta;
    IF total_unidades IS NULL THEN
        RETURN 0;
    END IF;
    SET peso_total  = total_unidades * peso_por_unidad;
    SET costo_envio = peso_total * costo_por_kg;
    RETURN costo_envio;
END $$
DELIMITER ;

-- prueba
SELECT 
    id_venta,
    total,
    fn_CalcularCostoEnvio(id_venta) AS costo_envio
FROM ventas
LIMIT 10;


-- 8: fn_AplicarDescuento: Aplica un porcentaje de descuento a un monto dado.
DELIMITER $$
CREATE FUNCTION fn_AplicarDescuento(
    p_monto DECIMAL(10,2),
    p_descuento DECIMAL(5,2)   -- porcentaje, ejemplo: 15 = 15%
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE monto_final DECIMAL(10,2);
    IF p_descuento < 0 OR p_descuento > 100 THEN
        RETURN NULL;  
    END IF;
    SET monto_final = p_monto - (p_monto * (p_descuento / 100));
    RETURN monto_final;
END $$
DELIMITER ;

-- prueba con 15% de descuento
SELECT 
    nombre,
    precio,
    fn_AplicarDescuento(precio, 15) AS precio_con_descuento
FROM productos
LIMIT 5;

-- 9: fn_ObtenerUltimaFechaCompra: Devuelve la fecha de la última compra de un cliente.
DELIMITER $$
CREATE FUNCTION fn_ObtenerUltimaFechaCompra(p_id_cliente INT)
RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE ultima_fecha DATETIME;
    SELECT MAX(fecha_venta)
    INTO ultima_fecha
    FROM ventas
    WHERE id_cliente = p_id_cliente
      AND estado NOT IN ('cancelado', 'pendiente_pago');
    RETURN ultima_fecha;  -- devuelve NULL si no tiene compras
END $$
DELIMITER ;

-- prueba
SELECT
    id_cliente,
    CONCAT(nombre, ' ', apellido) AS cliente,
    fn_ObtenerUltimaFechaCompra(id_cliente) AS ultima_compra
FROM clientes;

-- 10: fn_ValidarFormatoEmail: Comprueba si una cadena de texto tiene un formato de correo electrónico válido.
DELIMITER $$
CREATE FUNCTION fn_ValidarFormatoEmail(p_email VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    IF p_email like '%@%' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $$
DELIMITER ;

-- prueba con varios correos
SELECT fn_ValidarFormatoEmail('juan@gmail.com')   AS valido;    -- TRUE
SELECT fn_ValidarFormatoEmail('correosinArroba')  AS invalido;  -- FALSE
SELECT fn_ValidarFormatoEmail('raro@sin-punto')   AS invalido;  -- FALSE



-- 11. Devuelve el nombre de la categoria a partir del ID 

CREATE FUNCTION obtener_nombreXcategoria (p_id_producto int)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	DECLARE nombreC VARCHAR(100);
	
	SELECT c.nombre 
	INTO nombreC
	FROM categorias c 
	JOIN productos p ON p.categoria = c.id_categoria 
	WHERE p.id_producto = p_id_producto;
	
	RETURN nombreC;
END;

SELECT obtener_nombreXcategoria(2);

-- 12. Cuenta el numero total de compras realizadas por un cliente

CREATE FUNCTION contarVentasCliente (c_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE totalventas INT;

	SELECT COUNT(v.id_venta ) 
	INTO totalventas
	FROM ventas v 
	WHERE v.id_cliente = c_id_cliente;
	
	RETURN totalventas;
END;

SELECT contarVentasCliente(1);

-- 13. devolver el numero de dias transcurridos desde la ultima compra de un cliente

CREATE FUNCTION calcular_dias_ultima_compra (c_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE diastotales INT;
	
	SELECT DATEDIFF(MAX(v.fecha_venta), MIN(v.fecha_venta))
	INTO diastotales
	FROM ventas v
	WHERE v.id_cliente = c_id_cliente;
	
	RETURN diastotales;
END;

SELECT calcular_dias_ultima_compra (1);


-- 14. Asignar un estado de lealtad a un cliente segun su gasto total

CREATE FUNCTION asignar_lealtad (c_id_cliente INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE estado VARCHAR(50);
	DECLARE totalventas INT;
	
	SELECT COUNT(v.id_venta) 
	INTO totalventas
	FROM ventas v
	WHERE v.id_cliente = c_id_cliente;
	
	IF totalventas <= 2 
		THEN SET estado = 'pobre';
	
	ELSEIF  totalventas > 2 AND totalventas <= 4
		THEN SET estado = 'Plata';
	
	ELSEIF totalventas > 4
		THEN SET  estado = 'Oro';
	
	END IF;
	
	RETURN estado;
END;

SELECT asignar_lealtad(6);

-- 15. Genera  codigo de producto (supongo solo testear, osea como una funcion hipotetica)

CREATE FUNCTION generarSKU (p_id_producto INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	
	RETURN CONCAT('VIN-', LPAD(p_id_producto, 6, '0'));
END;

SELECT generarSKU (15);

-- LPAD =(rellenar una cadena de texto por la izquierda con un carácter o secuencia específica)
-- Usualmente usado para codigos y 
