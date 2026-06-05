drop database if exists proyectoSQL;
create database proyectoSQL;
use proyectoSQL;


-- ===================================
-- Creacion de tablas
-- ===================================

CREATE TABLE categorias(
	id_categoria INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) UNIQUE NOT NULL,
	descripcion VARCHAR(100)
);

CREATE TABLE proveedores(
	id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	email_contcto VARCHAR(100) UNIQUE,
	telefono VARCHAR(15)
);

create table sucursal (
	id_sucursal int auto_increment primary key,
	nombre varchar(100),
	codigo varchar(20),
	direccion varchar(255),
	telefono varchar(20), 
	email varchar(100),
	estado enum('Activa', 'Inactiva', 'Cerrada')
);

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre varchar(50),
    apellido VARCHAR(70),
    email VARCHAR(100),
    contrasena VARCHAR(200) NOT NULL,
    direccion_envio VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 


CREATE TABLE productos(
	id_producto INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	descripcion VARCHAR(255),
	categoria INT,
	proveedor INT,
	precio DECIMAL(10,2) NOT NULL,
	costo DECIMAL(10,2) NOT NULL,
	stock INT DEFAULT 0 NOT NULL,
	sku VARCHAR(20) UNIQUE NOT NULL,
	fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	activo BOOLEAN NOT NULL DEFAULT FALSE,
	
	FOREIGN KEY(categoria) REFERENCES categorias(id_categoria),
	FOREIGN KEY(proveedor) REFERENCES proveedores(id_proveedor)
);

DROP TABLE IF EXISTS ventas;
CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('pendiente_pago','procesando', 'enviado', 'entregado', 'cancelado'),
    total DECIMAL(10,2),
    id_sucursal int,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY(id_sucursal) REFERENCES sucursal(id_sucursal)
);

CREATE TABLE detalle_ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario_congelado DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


-- encriptacion contraseña insert
delimiter //
CREATE TRIGGER tr_hash_contraseña
BEFORE INSERT  ON clientes
FOR EACH ROW
BEGIN
	SET NEW.contrasena = SHA2(NEW.contrasena,256);
end // 
delimiter

-- encriptacion contraseña update
delimiter //
CREATE TRIGGER tr_hash_contraseña_update
BEFORE UPDATE  ON clientes
FOR EACH ROW
BEGIN
	IF NEW.contrasena <> OLD.contrasena THEN
		SET NEW.contrasena = SHA2(NEW.contrasena,256);
	END IF;
end //
delimiter

-- ===================================
-- Insercion de datos
-- ===================================

-- CATEGORIAS
INSERT INTO categorias(nombre, descripcion) VALUES
('Rock', 'Vinilos de rock clásico y moderno'),
('Pop', 'Vinilos de música pop'),
('Jazz', 'Vinilos de jazz y blues'),
('Metal', 'Vinilos de heavy metal y subgéneros'),
('Hip Hop', 'Vinilos de rap y hip hop'),
('Electrónica', 'Vinilos de música electrónica'),
('Reggae', 'Vinilos de reggae y ska'),
('Salsa', 'Vinilos de salsa y música tropical'),
('Clásica', 'Vinilos de música clásica'),
('Indie', 'Vinilos de rock y pop independiente');

-- PROVEEDORES
INSERT INTO proveedores(nombre,email_contcto,telefono) VALUES
('Vinyl Records Colombia','ventas@vinylrecords.com','3001111111'),
('Music Collection SAS','contacto@musiccollection.com','3002222222'),
('Retro Discos','info@retrodiscos.com','3003333333'),
('Golden Vinyl','ventas@goldenvinyl.com','3004444444'),
('Classic Sounds','contacto@classicsounds.com','3005555555');

-- SUCURSAL
INSERT INTO sucursal (nombre, codigo, direccion, telefono, email) VALUES
(
    'Medellín',
    'MED001',
    'Carrera 43A #1 Sur-150, Medellín',
    '6045551001',
    'medellin@vinylstore.com'
),
(
    'Bogotá',
    'BOG001',
    'Calle 72 #10-34, Bogotá',
    '6015551002',
    'bogota@vinylstore.com'
),
(
    'Cartagena',
    'CTG001',
    'Avenida San Martín #8-50, Cartagena',
    '6055551003',
    'cartagena@vinylstore.com'
),
(
    'Bucaramanga',
    'BGA001',
    'Carrera 27 #36-14, Bucaramanga',
    '6075551004',
    'bucaramanga@vinylstore.com'
);

-- CLIENTES
INSERT INTO clientes(nombre,apellido,email,contrasena,direccion_envio) VALUES
('Juan','Perez','juan@gmail.com','123456','Bogotá'),
('Maria','Gomez','maria@gmail.com','123456','Medellín'),
('Carlos','Lopez','carlos@gmail.com','123456','Cali'),
('Ana','Martinez','ana@gmail.com','123456','Barranquilla'),
('Pedro','Ramirez','pedro@gmail.com','123456','Bucaramanga'),
('Laura','Rodriguez','laura@gmail.com','123456','Cartagena'),
('Andres','Torres','andres@gmail.com','123456','Pereira'),
('Sofia','Diaz','sofia@gmail.com','123456','Manizales'),
('Daniel','Castro','daniel@gmail.com','123456','Tunja'),
('Valentina','Moreno','valentina@gmail.com','123456','Cúcuta'),
('Miguel','Rojas','miguel@gmail.com','123456','Ibagué'),
('Camila','Vargas','camila@gmail.com','123456','Neiva'),
('Jorge','Suarez','jorge@gmail.com','123456','Montería'),
('Paula','Herrera','paula@gmail.com','123456','Santa Marta');

-- PRODUCTOS
INSERT INTO productos
(nombre,descripcion,categoria,proveedor,precio,costo,stock,sku,activo)
VALUES
('The Dark Side of the Moon','Pink Floyd',1,1,180000,120000,15,'VIN001',TRUE),
('The Wall','Pink Floyd',1,1,190000,125000,10,'VIN002',TRUE),
('Led Zeppelin IV','Led Zeppelin',1,2,175000,115000,12,'VIN003',TRUE),
('Back in Black','AC/DC',1,2,170000,110000,18,'VIN004',TRUE),
('Hotel California','Eagles',1,3,165000,105000,14,'VIN005',TRUE),

('Thriller','Michael Jackson',2,1,185000,125000,20,'VIN006',TRUE),
('Bad','Michael Jackson',2,1,180000,120000,15,'VIN007',TRUE),
('1989','Taylor Swift',2,2,200000,135000,12,'VIN008',TRUE),
('Future Nostalgia','Dua Lipa',2,2,190000,130000,10,'VIN009',TRUE),
('Teenage Dream','Katy Perry',2,3,170000,110000,8,'VIN010',TRUE),

('Kind of Blue','Miles Davis',3,3,210000,145000,7,'VIN011',TRUE),
('Blue Train','John Coltrane',3,3,220000,150000,5,'VIN012',TRUE),
('Time Out','Dave Brubeck',3,4,205000,140000,6,'VIN013',TRUE),
('A Love Supreme','John Coltrane',3,4,215000,145000,8,'VIN014',TRUE),
('Head Hunters','Herbie Hancock',3,5,210000,145000,6,'VIN015',TRUE),

('Master of Puppets','Metallica',4,1,195000,130000,10,'VIN016',TRUE),
('Ride the Lightning','Metallica',4,1,190000,125000,8,'VIN017',TRUE),
('Paranoid','Black Sabbath',4,2,180000,120000,12,'VIN018',TRUE),
('Painkiller','Judas Priest',4,2,185000,122000,7,'VIN019',TRUE),
('Rust in Peace','Megadeth',4,3,190000,125000,9,'VIN020',TRUE),

('Illmatic','Nas',5,3,175000,115000,11,'VIN021',TRUE),
('The Marshall Mathers LP','Eminem',5,4,185000,125000,10,'VIN022',TRUE),
('The Chronic','Dr. Dre',5,4,180000,120000,9,'VIN023',TRUE),
('Ready to Die','Notorious B.I.G.',5,5,175000,118000,8,'VIN024',TRUE),
('To Pimp a Butterfly','Kendrick Lamar',5,5,210000,145000,12,'VIN025',TRUE),

('Discovery','Daft Punk',6,1,220000,150000,10,'VIN026',TRUE),
('Random Access Memories','Daft Punk',6,1,225000,155000,9,'VIN027',TRUE),
('Play','Moby',6,2,180000,120000,8,'VIN028',TRUE),
('Immunity','Jon Hopkins',6,2,190000,125000,7,'VIN029',TRUE),
('Music for the Jilted Generation','Prodigy',6,3,200000,135000,6,'VIN030',TRUE),

('Legend','Bob Marley',7,3,185000,125000,20,'VIN031',TRUE),
('Exodus','Bob Marley',7,4,180000,120000,14,'VIN032',TRUE),
('Catch a Fire','Bob Marley',7,4,175000,115000,12,'VIN033',TRUE),
('Marcus Garvey','Burning Spear',7,5,170000,110000,8,'VIN034',TRUE),
('Equal Rights','Peter Tosh',7,5,165000,105000,10,'VIN035',TRUE),

('Siembra','Willie Colon & Ruben Blades',8,1,190000,130000,10,'VIN036',TRUE),
('Lo Mato','Willie Colon',8,2,175000,115000,8,'VIN037',TRUE),
('Celia y Johnny','Celia Cruz',8,2,180000,120000,12,'VIN038',TRUE),
('Comedia','Hector Lavoe',8,3,170000,110000,10,'VIN039',TRUE),
('Asalto Navideño','Hector Lavoe',8,3,175000,115000,8,'VIN040',TRUE),

('Las Cuatro Estaciones','Vivaldi',9,4,230000,160000,5,'VIN041',TRUE),
('Requiem','Mozart',9,4,220000,150000,6,'VIN042',TRUE),
('Sinfonía No. 5','Beethoven',9,5,225000,155000,5,'VIN043',TRUE),
('El Lago de los Cisnes','Tchaikovsky',9,5,210000,145000,4,'VIN044',TRUE),
('Canon in D','Pachelbel',9,5,200000,135000,7,'VIN045',TRUE),

('AM','Arctic Monkeys',10,1,180000,120000,14,'VIN046',TRUE),
('Currents','Tame Impala',10,2,210000,145000,12,'VIN047',TRUE),
('Is This It','The Strokes',10,3,190000,130000,10,'VIN048',TRUE),
('Funeral','Arcade Fire',10,4,195000,130000,8,'VIN049',TRUE),
('In Rainbows','Radiohead',10,5,220000,150000,9,'VIN050',TRUE);

-- VENTAS
INSERT INTO ventas(id_cliente, fecha_venta, estado, total, id_sucursal) VALUES
(1,'2025-01-03 10:15:22','entregado',1100000,1),
(2,'2025-01-05 14:32:10','entregado',1300000,2),
(3,'2025-01-08 09:21:44','procesando',760000,3),
(4,'2025-01-12 18:05:33','enviado',1130000,4),
(5,'2025-01-15 11:42:18','entregado',1400000,1),
(1,'2025-01-20 16:30:45','entregado',1470000,2),
(6,'2025-02-02 08:50:11','cancelado',880000,3),
(7,'2025-02-04 13:25:19','entregado',1105000,4),
(8,'2025-02-08 19:40:27','entregado',1300000,1),
(9,'2025-02-11 10:12:54','pendiente_pago',850000,2),
(10,'2025-02-15 15:48:03','entregado',1175000,3),
(11,'2025-02-20 12:37:26','enviado',1020000,4),
(12,'2025-03-03 09:10:17','entregado',1260000,1),
(13,'2025-03-07 17:55:49','procesando',1285000,2),
(14,'2025-03-11 14:21:08','entregado',895000,3),
(5,'2025-03-15 11:33:42','entregado',1465000,4),
(2,'2025-03-18 20:05:11','entregado',1820000,1),
(8,'2025-03-22 16:17:35','procesando',1270000,2),
(1,'2025-04-02 10:45:28','enviado',1325000,3),
(3,'2025-04-06 13:22:51','entregado',1145000,4),
(4,'2025-04-10 18:36:07','entregado',1075000,1),
(5,'2025-04-15 09:55:14','pendiente_pago',1090000,2),
(6,'2025-04-20 15:42:39','entregado',1620000,3),
(7,'2025-04-24 12:08:26','cancelado',1085000,4),
(8,'2025-05-04 17:15:42','entregado',1545000,1),
(9,'2025-05-09 11:29:31','entregado',1075000,2),
(10,'2025-05-15 14:50:08','procesando',2225000,3),
(11,'2025-05-21 19:12:55','entregado',1030000,4),
(12,'2025-05-27 16:44:19','enviado',1070000,1),
(1,'2025-06-03 20:35:47','entregado',2975000,2);


-- DETALLES
INSERT INTO detalle_ventas
(id_venta, id_producto, cantidad, precio_unitario_congelado)
VALUES
(1,1,1,180000),
(1,6,1,185000),
(1,31,1,185000),
(2,6,2,185000),
(2,8,1,200000),
(3,16,1,195000),
(3,18,1,180000),
(4,21,2,175000),
(4,25,1,210000),
(5,46,1,180000),
(5,47,1,210000),
(5,48,1,190000),
(6,1,2,180000),
(6,2,1,190000),
(7,31,1,185000),
(7,32,1,180000),
(8,36,2,190000),
(8,38,1,180000),
(9,46,2,180000),
(9,6,1,185000),
(10,41,1,230000),
(11,25,2,210000),
(11,1,1,180000),
(12,47,1,210000),
(12,50,1,220000),
(13,31,2,185000),
(13,33,1,175000),
(14,8,1,200000),
(14,9,1,190000),
(14,10,1,170000),
(15,42,1,220000),
(15,43,1,225000),
(16,6,1,185000),
(16,31,1,185000),
(16,46,1,180000),
(17,1,1,180000),
(17,6,1,185000),
(17,7,1,180000),
(17,31,1,185000),
(18,47,2,210000),
(18,25,1,210000),
(19,46,1,180000),
(19,48,1,190000),
(19,49,1,195000),
(20,16,2,195000),
(20,20,1,190000),
(21,21,1,175000),
(21,22,1,185000),
(21,23,1,180000),
(22,26,1,220000),
(22,27,1,225000),
(23,31,3,185000),
(23,35,1,165000),
(24,36,1,190000),
(24,40,1,175000),
(25,46,1,180000),
(25,47,1,210000),
(25,50,1,220000),
(26,11,1,210000),
(26,12,1,220000),
(27,1,1,180000),
(27,6,1,185000),
(27,31,1,185000),
(27,46,1,180000),
(28,25,1,210000),
(28,47,1,210000),
(29,38,2,180000),
(29,39,1,170000),
(30,1,1,180000),
(30,6,2,185000),
(30,31,1,185000),
(30,46,1,180000);


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

-- ???? Nose aun a que se refiere con campaña de descuento

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


-- TIMESTAMPDIFF  (determinar el intervalo de tiempo entre dos fechas en una unidad de medida específica, lo que la hace ideal para 
-- cálculos de edad, mediciones de duración y cualquier análisis temporal.)

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


-- ===================================
-- Funciones
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

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

-- ===================================
-- Roles y permisos
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

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




-- ===================================
-- Triggers 
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

-- ===================================
-- Eventos
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================


-- ===================================
-- Procedimientos almacenados
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================
