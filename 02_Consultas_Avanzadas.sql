-- ====================================================
-- Consultas avanzadas
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

-- 1. Top 10 productos mas vendidos

SELECT productos.nombre, detalle_ventas.id_producto, SUM(detalle_ventas.cantidad) AS cantidad_vendida
FROM productos	
JOIN detalle_ventas ON detalle_ventas.id_producto = productos.id_producto   -- Falta excluir a los cancelados supongo (?)
GROUP BY productos.nombre, detalle_ventas.id_producto 
ORDER BY cantidad_vendida DESC
LIMIT 10;


-- 2. productos con bajas ventas ( 50 productos x 0.10 = 5) 5 productos menos vendidos 

SELECT productos.nombre, SUM(detalle_ventas.cantidad) AS cantidad_vendida, SUM(productos.precio * detalle_ventas.cantidad)
FROM productos	
JOIN detalle_ventas ON detalle_ventas.id_producto = productos.id_producto   -- Falta excluir a los cancelados supongo (?)
GROUP BY productos.nombre
ORDER BY cantidad_vendida ASC

-- no le puse el limitante de 5 productos ya que observando la tabla se puede percatar que hay mas de 5 en el rango de menos porcentaje de ventas
-- especificamente 10


-- 3. Clientes VIP, su gasto total historico (5)

SELECT c.nombre, SUM(dv.cantidad) as total_comprados
FROM ventas v
JOIN clientes c ON c.id_cliente = v.id_cliente 
JOIN detalle_ventas dv ON dv.id_venta = v.id_venta 
GROUP BY c.nombre
ORDER BY total_comprados DESC
LIMIT 5;

-- 4. Analisis de ventas mensuales (meses y año)

SELECT v.id_venta,p.nombre, dv.precio_unitario_congelado, MONTH(v.fecha_venta) AS mes
FROM detalle_ventas dv 
JOIN productos p ON p.id_producto = dv.id_producto 
JOIN ventas v ON v.id_venta = dv.id_venta 
GROUP BY  v.id_venta, dv.id_venta, p.nombre, dv.precio_unitario_congelado

SELECT v.id_venta,p.nombre, dv.precio_unitario_congelado, YEAR(v.fecha_venta) AS mes
FROM detalle_ventas dv 
JOIN productos p ON p.id_producto = dv.id_producto 
JOIN ventas v ON v.id_venta = dv.id_venta 
GROUP BY YEAR(v.fecha_venta ), v.id_venta, dv.id_venta, p.nombre, dv.precio_unitario_congelado

-- 5. Calcular el numero de nuevos clientes registrados por trimestre

SELECT c.nombre,YEAR(c.fecha_registro ) as anio, QUARTER(c.fecha_registro) as trimestre
FROM clientes c
ORDER BY anio ASC

-- 6: Tasa de Compra Repetida: Determinar qué porcentaje de clientes ha realizado más de una compra.

select round((
	( select COUNT(*) 
	  FROM (
			select v.id_cliente
			from ventas v
			WHERE estado = 'entregado'
			GROUP BY id_cliente
			HAVING COUNT(*) > 1  
		) AS total_compras
	) 
/
	( 
	select count(distinct v.id_cliente)
	from ventas v
	where estado = 'entregado'
	)
),2) * 100 as tasa_compra_repetida;

-- 7: Productos Comprados Juntos Frecuentemente: Identificar pares de productos que a menudo se compran en la misma transacción.
SELECT 
    p1.nombre AS producto_1,
    p2.nombre AS producto_2,
    COUNT(*) AS veces_juntos
FROM detalle_ventas dv1
JOIN detalle_ventas dv2 
ON dv1.id_venta = dv2.id_venta        -- misma venta
AND dv1.id_producto < dv2.id_producto  -- evita duplicados como (A,B) y (B,A)
JOIN productos p1 ON dv1.id_producto = p1.id_producto
JOIN productos p2 ON dv2.id_producto = p2.id_producto
GROUP BY p1.nombre, p2.nombre
HAVING COUNT(*) >= 2                       -- solo pares que se repiten
ORDER BY veces_juntos DESC;

-- 8: Rotación de Inventario: Calcular la tasa de rotación de stock para cada categoría de producto.
SELECT 
    c.nombre AS categoria,
    SUM(dv.cantidad) AS total_vendido,
    SUM(p.stock) AS stock_actual,
    ROUND(SUM(dv.cantidad) / NULLIF(SUM(p.stock), 0), 2) AS tasa_rotacion
FROM categorias c
JOIN productos p ON p.categoria = c.id_categoria
JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
GROUP BY c.nombre
ORDER BY tasa_rotacion DESC;

-- 9: Productos que Necesitan Reabastecimiento: Listar productos cuyo stock actual está por debajo de su umbral mínimo.
SELECT 
    p.nombre AS producto,
    p.sku,
    c.nombre AS categoria,
    p.stock AS stock_actual,
    8 AS stock_minimo,                    -- stock fijo
    (8 - p.stock) AS unidades_faltantes
FROM productos p
JOIN categorias c ON p.categoria = c.id_categoria
WHERE p.stock < 8
  AND p.activo = TRUE
ORDER BY p.stock ASC;                     -- los más críticos primero

-- 10: Análisis de Carrito Abandonado (Simulado): Identificar clientes que agregaron productos pero no completaron una venta en un período determinado.
SELECT 
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    cl.email,
    v.estado,
    v.fecha_venta,
    p.nombre AS producto_no_comprado,
    dv.cantidad,
    dv.precio_unitario_congelado
FROM ventas v
JOIN clientes cl ON v.id_cliente = cl.id_cliente
JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
JOIN productos p ON dv.id_producto = p.id_producto
WHERE v.estado IN ('pendiente_pago', 'cancelado')
  -- ventas del último mes, ajusta la fecha según necesites
  AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
ORDER BY cl.nombre, v.fecha_venta;

-- 11. Clasificar a los proveedores segun que tanto se venden sus productos

SELECT p.proveedor, p.nombre AS producto, SUM(dv.cantidad ) AS cantidadVendida
FROM productos p 
JOIN detalle_ventas dv ON dv.id_producto = p.id_producto 
GROUP BY p.proveedor, p.nombre 
ORDER BY cantidadVendida  DESC

-- 12. Agrupar las ventas por ciudad o region del cliente

SELECT v.id_venta, c.nombre, c.direccion_envio 
FROM ventas v 
JOIN clientes c ON c.id_cliente = v.id_cliente 

-- 13. Determinar las horas pico de compras 

SELECT HOUR(fecha_venta ), COUNT(*) AS repetidas
FROM ventas v 
GROUP BY HOUR(fecha_venta)
ORDER BY repetidas DESC

-- 14. Comparar las ventas de un producto antes y despues de una campaña de descuento

SELECT
	    'Antes' AS periodo,
	    SUM(dv.cantidad) AS unidades_vendidas,
	    SUM(dv.cantidad * dv.precio_unitario_congelado) AS total_vendido
	FROM detalle_ventas dv
	JOIN ventas v ON dv.id_venta = v.id_venta
	WHERE dv.id_producto = 1
	AND v.fecha_venta < '2025-03-01'   -- ingresar las fechas manuales dependiendo la temporada de camañan.. supongo xd
	
	UNION
	
	SELECT
	    'Despues' AS periodo,
	    SUM(dv.cantidad) AS unidades_vendidas,
	    SUM(dv.cantidad * dv.precio_unitario_congelado) AS total_vendido
	FROM detalle_ventas dv
	JOIN ventas v ON dv.id_venta = v.id_venta
	WHERE dv.id_producto = 1
	AND v.fecha_venta >= '2025-03-01';

-- 15. Retencion de cliente mes a mes desde su primera compra

SELECT c.nombre, MIN(DATE(v.fecha_venta)) AS primera_compra,
CASE
	WHEN MIN(DATE(v.fecha_venta)) = MAX(DATE(v.fecha_venta))
	THEN 'no tiene ultima compra'
 	ELSE CONCAT(TIMESTAMPDIFF(MONTH, MIN(DATE(v.fecha_venta)), MAX(DATE(v.fecha_venta))),' meses despues')
END AS meses_despues_de_la_ultima_compra
FROM ventas v
JOIN clientes c ON c.id_cliente = v.id_cliente 
WHERE estado <> 'cancelado'
GROUP BY c.id_cliente;

-- 16: Margen de Beneficio por Producto: Calcular el margen de beneficio para cada producto (requiere añadir un campo costo a la tabla productos).
SELECT
    p.nombre AS producto,
    c.nombre AS categoria,
    p.precio,
    p.costo,
    (p.precio - p.costo) AS ganancia_por_unidad,
    ROUND(((p.precio - p.costo) / p.precio) * 100, 2) AS margen_porcentaje
FROM productos p
JOIN categorias c ON p.categoria = c.id_categoria
WHERE p.activo = TRUE
ORDER BY margen_porcentaje DESC;


-- 17: Tiempo Promedio Entre Compras: Calcular el tiempo medio que tarda un cliente en volver a comprar.
SELECT
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    COUNT(v.id_venta) AS total_compras,
    ROUND(AVG(dias_entre_compras), 0) AS promedio_dias_entre_compras
FROM clientes cl
JOIN (
    SELECT
        id_cliente,
        fecha_venta,
        id_venta,
        DATEDIFF(
            fecha_venta,
            LAG(fecha_venta) OVER (PARTITION BY id_cliente ORDER BY fecha_venta)
        ) AS dias_entre_compras
    FROM ventas v
    WHERE estado NOT IN ('cancelado', 'pendiente_pago')
) v ON cl.id_cliente = v.id_cliente
GROUP BY cl.id_cliente, cl.nombre, cl.apellido
HAVING COUNT(v.id_venta) >= 2  
ORDER BY promedio_dias_entre_compras ASC;

-- 18: Productos Más Vistos vs. Comprados: Comparar los productos más visitados con los más comprados.
SELECT
    ROW_NUMBER() OVER (ORDER BY SUM(dv.cantidad) DESC) AS puesto,
    p.nombre AS producto,
    c.nombre AS categoria,
    SUM(dv.cantidad) AS unidades_vendidas,
    COUNT(DISTINCT dv.id_venta) AS aparece_en_ventas,
    p.precio,
    p.stock AS stock_actual

FROM detalle_ventas dv
JOIN productos p ON dv.id_producto = p.id_producto
JOIN categorias c ON p.categoria = c.id_categoria
JOIN ventas v ON dv.id_venta = v.id_venta

-- no contar ventas canceladas o sin pagar
WHERE v.estado NOT IN ('cancelado', 'pendiente_pago')

GROUP BY p.id_producto, p.nombre, c.nombre, p.precio, p.stock
ORDER BY unidades_vendidas DESC;

-- 19: Segmentación de Clientes (RFM): Clasificar a los clientes en segmentos (Recencia, Frecuencia, Monetario).
WITH rfm_base AS (
    SELECT
        cl.id_cliente,
        CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
        DATEDIFF(NOW(), MAX(v.fecha_venta)) AS recencia,
        COUNT(v.id_venta) AS frecuencia,
        SUM(v.total) AS monetario
    FROM clientes cl
    JOIN ventas v ON cl.id_cliente = v.id_cliente
    WHERE v.estado NOT IN ('cancelado', 'pendiente_pago')
    GROUP BY cl.id_cliente, cl.nombre, cl.apellido
),
rfm_scores AS (
    SELECT *,
        CASE
            WHEN recencia <= 30  THEN 3
            WHEN recencia <= 90  THEN 2
            ELSE 1
        END AS score_r,
        CASE
            WHEN frecuencia >= 3 THEN 3
            WHEN frecuencia = 2  THEN 2
            ELSE 1
        END AS score_f,
        CASE
            WHEN monetario >= 1500000 THEN 3
            WHEN monetario >= 800000  THEN 2
            ELSE 1
        END AS score_m
    FROM rfm_base
)
SELECT
    cliente,
    recencia,
    frecuencia,
    monetario,
    (score_r + score_f + score_m) AS rfm_total,
    CASE
        WHEN (score_r + score_f + score_m) >= 8 THEN 'Cliente VIP'
        WHEN (score_r + score_f + score_m) >= 6 THEN 'Cliente Leal'
        WHEN (score_r + score_f + score_m) >= 4 THEN 'Cliente Potencial'
        ELSE 'Cliente en Riesgo'
    END AS segmento
FROM rfm_scores
ORDER BY rfm_total DESC;

-- 20: Predicción de Demanda Simple: Utilizar datos de ventas pasadas para proyectar las ventas del próximo mes para una categoría específica.
WITH ventas_por_mes AS (
    SELECT
        c.nombre AS categoria,
        DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes,
        SUM(dv.cantidad) AS unidades_vendidas
    FROM detalle_ventas dv
    JOIN ventas v ON dv.id_venta = v.id_venta
    JOIN productos p ON dv.id_producto = p.id_producto
    JOIN categorias c ON p.categoria = c.id_categoria
    WHERE v.estado NOT IN ('cancelado', 'pendiente_pago')
    GROUP BY c.nombre, DATE_FORMAT(v.fecha_venta, '%Y-%m')
)
SELECT
    categoria,
    COUNT(mes) AS meses_con_datos,
    ROUND(AVG(unidades_vendidas), 0) AS promedio_mensual,
    ROUND(AVG(unidades_vendidas) * 1.05, 0) AS proyeccion_proximo_mes
FROM ventas_por_mes
GROUP BY categoria
ORDER BY proyeccion_proximo_mes DESC;



