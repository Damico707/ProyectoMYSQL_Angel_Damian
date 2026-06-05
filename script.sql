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

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre varchar(50),
    apellido VARCHAR(70),
    email VARCHAR(100),
    contrasena VARCHAR(200) NOT NULL,
    direccion_envio VARCHAR(100),
    fecha_registro TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
);

DROP TABLE IF EXISTS ventas;
CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('pendiente_pago','procesando', 'enviado', 'entregado', 'cancelado'),
    total DECIMAL(10,2),
    
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
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
INSERT INTO ventas(id_cliente, estado, total) VALUES
(1,'entregado',550000),
(2,'entregado',570000),
(3,'procesando',375000),
(4,'enviado',560000),
(5,'entregado',580000),
(1,'entregado',550000),
(6,'cancelado',365000),
(7,'entregado',560000),
(8,'entregado',545000),
(9,'pendiente_pago',230000),
(10,'entregado',600000),
(11,'enviado',430000),
(12,'entregado',545000),
(13,'procesando',560000),
(14,'entregado',445000),
(5,'entregado',550000),
(2,'entregado',730000),
(8,'procesando',630000),
(1,'enviado',565000),
(3,'entregado',580000),
(4,'entregado',540000),
(5,'pendiente_pago',445000),
(6,'entregado',720000),
(7,'cancelado',365000),
(8,'entregado',610000),
(9,'entregado',430000),
(10,'procesando',730000),
(11,'entregado',420000),
(12,'enviado',530000),
(1,'entregado',915000);

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



-- ===================================
-- Funciones
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================


-- ===================================
-- Roles y permisos
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

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
