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
    fecha_nacimiento DATE,
    contrasena VARCHAR(200) NOT NULL,
    direccion_envio VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
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

CREATE TABLE logs_cambios_precio (
	id INT AUTO_INCREMENT PRIMARY KEY,
	id_producto INT NOT NULL,
	precio_anterior DECIMAL(10,2),
	precio_nuevo DECIMAL(10,2),
	fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

 CREATE TABLE auditoria_clientes(
 		id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 		id_cliente INT NOT NULL,
 		mensaje VARCHAR(100)
 );

 CREATE TABLE auditoria_estado_pedido(
 	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 	id_venta INT NOT NULL,
 	estado_anterior VARCHAR(100),
 	estado_actual VARCHAR(100)
 );
 
	CREATE TABLE alertas_stock (
		id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		id_producto INT NOT NULL,
		stockACT INT,
		fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	
	CREATE TABLE ventas_eliminadas(
		id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		id_venta INT NOT NULL,
		id_cliente INT NOT NULL,
		estado VARCHAR(100),
		total DECIMAL(10,2),
		fecha_eliminacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);


create table lista_reabastecimiento(
	id_producto int,
	nombre varchar(100),
	stock_actual int,
	fecha_generacion timestamp default current_timestamp
);

create table ventas_diarias(
	id_venta int,
	id_producto int,
	id_cliente int,
	fecha_venta timestamp
);

create table inconsistencias(
	id_inconsistencia int auto_increment primary key,
	tipo varchar(100),
	descripcion varchar(255),
	fecha_revision timestamp default current_timestamp
);

create table mv_ventas_por_categoria(
	categoria varchar(100),
	total_ventas decimal(12,2)
);

create table log_tamano_db(
	id_log int auto_increment primary key,
	fecha_registro timestamp default current_timestamp,
	tamano_db decimal(10,2)
);

create table actividad_sospechosa(
	id_actividad int auto_increment primary key,
	id_cliente int,
	nombre varchar(100),
	cantidad_cancelados int,
	fecha_deteccion timestamp default current_timestamp
);

create table reporte_proveedores(
	id_proveedor int,
	proveedor varchar(100),
	total_ventas decimal(12,2),
	unidades_vendidas int,
	pediddos_participados int,
	fecha_reporte date
);
-- ==========================
-- ÍNDICES
-- ==========================

CREATE INDEX idx_ventas_cliente
ON ventas(id_cliente);

CREATE INDEX idx_ventas_sucursal
ON ventas(id_sucursal);

CREATE INDEX idx_productos_categoria
ON productos(categoria);

CREATE INDEX idx_productos_proveedor
ON productos(proveedor);

CREATE INDEX idx_detalle_venta
ON detalle_ventas(id_venta);


-- ==========================
-- ENCRIPTACIONES CONTRASEÑAS
-- ==========================
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

-- CLIENTES
INSERT INTO clientes
(nombre,apellido,email,fecha_nacimiento,contrasena,direccion_envio,fecha_registro)
VALUES
('Juan','Perez','juan@gmail.com','1985-07-12','123456','Bogotá','2022-03-15 10:25:30'),
('Maria','Gomez','maria@gmail.com','1990-11-25','123456','Medellín','2022-07-21 14:12:45'),
('Carlos','Lopez','carlos@gmail.com','1988-04-18','123456','Cali','2022-11-05 09:40:10'),
('Ana','Martinez','ana@gmail.com','1995-09-30','123456','Barranquilla','2023-01-18 16:20:55'),
('Pedro','Ramirez','pedro@gmail.com','1982-01-15','123456','Bucaramanga','2023-04-09 11:15:22'),
('Laura','Rodriguez','laura@gmail.com','1993-06-22','123456','Cartagena','2023-06-27 18:05:41'),
('Andres','Torres','andres@gmail.com','1987-12-08','123456','Pereira','2023-09-12 08:33:17'),
('Sofia','Diaz','sofia@gmail.com','1998-03-14','123456','Manizales','2024-02-14 13:22:36'),
('Daniel','Castro','daniel@gmail.com','1991-08-27','123456','Tunja','2024-05-30 15:48:12'),
('Valentina','Moreno','valentina@gmail.com','1999-05-05','123456','Cúcuta','2024-08-07 10:17:29'),
('Miguel','Rojas','miguel@gmail.com','1984-10-19','123456','Ibagué','2024-10-25 19:02:44'),
('Camila','Vargas','camila@gmail.com','1997-02-11','123456','Neiva','2025-01-11 12:45:38'),
('Jorge','Suarez','jorge@gmail.com','1980-09-03','123456','Montería','2025-03-22 17:28:51'),
('Paula','Herrera','paula@gmail.com','1996-12-17','123456','Santa Marta','2025-06-08 09:14:27');

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
(1,1,2,180000),
(1,6,3,185000),
(1,31,1,185000),
(2,6,4,185000),
(2,8,1,200000),
(2,46,2,180000),
(3,16,2,195000),
(3,18,1,180000),
(3,20,1,190000),
(4,21,3,175000),
(4,25,2,210000),
(4,22,1,185000),
(5,46,2,180000),
(5,47,3,210000),
(5,48,1,190000),
(5,50,1,220000),
(6,1,3,180000),
(6,2,1,190000),
(6,6,2,185000),
(6,31,2,185000),
(7,31,2,185000),
(7,32,1,180000),
(7,35,2,165000),
(8,36,3,190000),
(8,38,2,180000),
(8,40,1,175000),
(9,46,4,180000),
(9,6,2,185000),
(9,47,1,210000),
(10,41,1,230000),
(10,45,2,200000),
(10,42,1,220000),
(11,25,3,210000),
(11,1,2,180000),
(11,6,1,185000),
(12,47,2,210000),
(12,50,1,220000),
(12,48,2,190000),
(13,31,4,185000),
(13,33,2,175000),
(13,34,1,170000),
(14,8,2,200000),
(14,9,1,190000),
(14,10,3,170000),
(14,6,1,185000),
(15,42,2,220000),
(15,43,1,225000),
(15,41,1,230000),
(16,6,3,185000),
(16,31,2,185000),
(16,46,2,180000),
(16,1,1,180000),
(17,1,4,180000),
(17,6,3,185000),
(17,7,2,180000),
(17,31,1,185000),
(18,47,3,210000),
(18,25,2,210000),
(18,50,1,220000),
(19,46,3,180000),
(19,48,2,190000),
(19,49,1,195000),
(19,47,1,210000),
(20,16,3,195000),
(20,20,2,190000),
(20,18,1,180000),
(21,21,2,175000),
(21,22,2,185000),
(21,23,1,180000),
(21,24,1,175000),
(22,26,2,220000),
(22,27,2,225000),
(22,30,1,200000),
(23,31,5,185000),
(23,35,2,165000),
(23,6,1,185000),
(23,1,1,180000),
(24,36,2,190000),
(24,40,3,175000),
(24,38,1,180000),
(25,46,4,180000),
(25,47,2,210000),
(25,50,1,220000),
(25,6,1,185000),
(26,11,2,210000),
(26,12,2,220000),
(26,14,1,215000),
(27,1,2,180000),
(27,6,4,185000),
(27,31,3,185000),
(27,46,2,180000),
(27,47,1,210000),
(28,25,2,210000),
(28,47,2,210000),
(28,48,1,190000),
(29,38,3,180000),
(29,39,2,170000),
(29,36,1,190000),
(30,1,5,180000),
(30,6,4,185000),
(30,31,3,185000),
(30,46,2,180000),
(30,47,2,210000);


-- ====================================================
-- ALTER TABLES
-- ====================================================

-- TRIGGERS

-- 6
alter table clientes 
add total_gastado decimal(10,2);

-- 7
alter table productos 
add column fecha_modificacion timestamp null;

-- 16
alter table clientes 
add column ultimo_pedido timestamp null;

-- 17 
alter table clientes 
add column cliente_referido int, 
add foreign key (cliente_referido) references clientes(id_cliente);

-- 20
alter table categorias 
add column total_productos int default 0;

-- EVENTS

-- 8
alter table clientes 
add column estado enum('activo', 'inactivo') default 'activo';

-- event 20
alter table productos 
add column eliminado boolean default false,
add column fecha_eliminacion timestamp null;
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

-- ===================================
-- TRIGGERS
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

-- 1. guarda un log de cambios de precios
	CREATE TRIGGER trg_audit_precio_producto_after_update
	AFTER UPDATE ON productos
	FOR EACH ROW
	BEGIN
		INSERT INTO logs_cambios_precio(id_producto,precio_anterior, precio_nuevo) VALUES 
		(OLD.id_producto, OLD.precio, NEW.precio);
	END;
	
	
UPDATE productos
SET precio = 200000
WHERE id_producto = 1;
	

-- 2. verificar el stock antes de registrar una venta

	CREATE TRIGGER trg_check_stock_before_insert_venta 
	BEFORE INSERT ON detalle_ventas
	FOR EACH ROW
	BEGIN
		
		DECLARE v_stock INT;
		
		SELECT stock
		INTO v_stock
		FROM productos
		WHERE id_producto = NEW.id_producto;
		
		IF v_stock < NEW.cantidad THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El producto se agoto :(';
		END IF;
	END;
	
INSERT INTO detalle_ventas
(id_venta, id_producto, cantidad, precio_unitario_congelado)
VALUES
(31, 1, 20, 180000);

-- 3.  Decrementa el stock después de una venta.

	CREATE TRIGGER trg_update_stock_after_insert_venta
	AFTER INSERT INTO detalle_ventas
	FOR EACH ROW
	BEGIN
	    UPDATE productos
	    SET stock = stock - NEW.cantidad
	    WHERE id_producto = NEW.id_producto;
	END;
	
-- 4. Impedir eliminar una categoria si tiene productos asociados
		
	CREATE TRIGGER trg_prevent_delete_categoria_with_products
	BEFORE DELETE ON categorias
	FOR EACH ROW
	BEGIN
	
	    DECLARE cantidadProductos INT;
	
	    SELECT COUNT(*)
	    INTO cantidadProductos
	    FROM productos
	    WHERE categoria = OLD.id_categoria;
	
	    IF cantidadProductos > 0 THEN
	        SIGNAL SQLSTATE '45000'
	        SET MESSAGE_TEXT = 'Error: la categoria tiene productos asociados';
	    END IF;
	END;
		    
 	DELETE FROM categorias
	WHERE id_categoria = 1;
 	
 -- 5. Registra en una tabla de auditoría cada vez que se crea un nuevo cliente.
 	
 	CREATE TRIGGER trg_log_new_customer_after_insert 
 	AFTER INSERT ON clientes
 	FOR EACH ROW
 	BEGIN
 		INSERT INTO auditoria_clientes (id_cliente, mensaje)
 		VALUES (NEW.id_cliente, CONCAT('Se ha añadido un nuevo cliente de id: ',NEW.id_cliente));
 	END;
 	
 	INSERT INTO clientes
	(nombre, apellido, email, fecha_nacimiento, contrasena, direccion_envio)
	VALUES
	('Luis', 'Mendoza', 'luis@gmail.com', '1994-05-10', '123456', 'Bogotá');

 -- 6. trg_update_total_gastado_cliente: Actualiza un campo total_gastado en la tabla clientes después de cada compra.

alter table clientes 
add total_gastado decimal(10,2);

delimiter //
create trigger trg_update_total_gastado_cliente
after insert 
on ventas
for each row
begin
	if new.estado = 'entregado' then
	update clientes
	set total_gastado = total_gastado + new.total
	where id_cliente = new.id_cliente;
	end if;
end //
delimiter

-- 7. trg_set_fecha_modificacion_producto: Actualiza automáticamente la fecha de última modificación de un producto.

alter table clientes 
add total_gastado decimal(10,2);

delimiter //
create trigger trg_set_fecha_modificacion_producto
before update 
on productos
for each row
begin
	set new.fecha_modificacion = current_timestamp;
end //
delimiter

-- 8. trg_prevent_negative_stock: Impide que el stock de un producto se actualice a un valor negativo.

delimiter //
create trigger trg_prevent_negative_stock
before update 
on productos 
for each row
begin
	if new.stock < 0 then
		SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'El stock no puede ser negativo';
	end if;
end //
delimiter

-- 9. trg_capitalize_nombre_cliente: Convierte a mayúscula la primera letra del nombre y apellido de un cliente al insertarlo.

delimiter //
create trigger trg_capitalize_nombre_cliente
before insert  
on clientes
for each row 
begin 
	SET new.nombre = CONCAT(UPPER(LEFT(new.nombre, 1)),LOWER(SUBSTRING(new.nombre, 2)));
	SET new.apellido = CONCAT(UPPER(LEFT(new.apellido, 1)),LOWER(SUBSTRING(new.apellido, 2)));
end //
delimiter

-- prueba
INSERT INTO clientes
(nombre, apellido, email, contrasena)
VALUES
('jUaN', 'péREZ', 'juan@test.com', '123');

select nombre, apellido 
from clientes 
where email = 'juan@test.com';

-- 10. trg_recalculate_total_venta_on_detalle_change: Recalcula el total en la tabla ventas si se modifica un detalle_venta.

delimiter //
create trigger trg_recalculate_total_venta_on_detalle_change
after update 
on ventas
for each row 
begin
	if estado = 'entregado' then
	set total = new.cantidad * precio
	where producto.id_producto = detalle_venta.id_producto
end //
delimiter ;

 -- 11. Audita cada cambio de estado en un pedido (ej. de 'Procesando' a 'Enviado').
 	
 	CREATE TRIGGER trg_log_order_status_change
 	AFTER UPDATE ON ventas
 	FOR EACH ROW
 	BEGIN
	 	
	 	 IF OLD.estado <> NEW.estado THEN
	 	    
 		INSERT INTO auditoria_estado_pedido (id_venta, estado_anterior, estado_actual)
 		VALUES (OLD.id_venta, OLD.estado, NEW.estado);
 		END IF;
 	END;
 	
 	UPDATE ventas
	SET estado = 'procesando'
	WHERE id_venta = 3;	

 -- 12. Impide que el precio de un producto se establezca en cero o un valor negativo.
 	
 	CREATE TRIGGER trg_prevent_price_zero_or_less
 	BEFORE INSERT ON productos
 	FOR EACH ROW
 	BEGIN
 		
 		IF NEW.precio <= 0 THEN 
 	        SIGNAL SQLSTATE '45000'
	        SET MESSAGE_TEXT = 'Error: el precio no puede ser negativo';
 		END IF;
 	END;
 	
	INSERT INTO productos
	(nombre, precio, stock, categoria, costo, sku)
	VALUES
	('Nuevo Vinilo', -4, 10, 1, 0, 90);
	
-- 13.  Inserta un registro en una tabla alertas si el stock baja de un umbral.
	
	CREATE TRIGGER trg_send_stock_alert_on_low_stock
	AFTER UPDATE ON productos
	FOR EACH ROW
	BEGIN
	    IF NEW.stock < 5 AND OLD.stock >= 5 THEN
	        INSERT INTO alertas_stock (id_producto, stockACT)
	        VALUES (NEW.id_producto, NEW.stock);
	    END IF;
	END;
	
	UPDATE productos
	SET stock = 4
	WHERE id_producto = 1;
	
-- 14.  Mueve una venta eliminada a una tabla de archivo en lugar de borrarla permanentemente.
	
	CREATE TRIGGER trg_archive_deleted_venta
	AFTER DELETE ON ventas
	FOR EACH ROW
	BEGIN
		INSERT INTO ventas_eliminadas (id_venta, id_cliente, estado, total) VALUES 
		(OLD.id_venta, OLD.id_cliente, OLD.estado, OLD.total);
	END;
	
	
	DELETE FROM detalle_ventas
	WHERE id_venta = 29;

	DELETE FROM ventas
	WHERE id_venta = 29;
	
-- 15.  Valida el formato del email antes de insertar o actualizar un cliente.
	
	CREATE TRIGGER trg_validate_email_format_on_customer
	BEFORE INSERT ON clientes
	FOR EACH ROW
	BEGIN
		
		IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Formato no valido';
		END IF;
	END;
		
	INSERT INTO clientes
	(nombre, email)
	VALUES
	('Juan', 'juan.gmail.com');
	
-- 16. trg_update_last_order_date_customer: Actualiza la fecha del último pedido en la tabla clientes.

alter table clientes 
add column ultimo_pedido timestamp null;	
	
delimiter //
create trigger trg_update_last_order_date_customer
after insert 
on ventas 
for each row
begin 
	update clientes
	set ultimo_pedido = new.fecha_venta
	where id_cliente = new.id_cliente;
end //
delimiter ;

-- 17. trg_prevent_self_referral: Impide que un cliente se referencie a sí mismo en un programa de referidos.

alter table clientes 
add column cliente_referido int, 
add foreign key (cliente_referido) references clientes(id_cliente);

delimiter //
create trigger trg_prevent_self_referral
before insert 
on clientes 
for each row
begin
	if new.cliente_referido = new.id_cliente then 
		SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'No se puede añadir usted mismo como referido';
	end if;
end //
delimiter ;

-- 18. trg_log_permission_changes: Audita los cambios en los permisos de los usuarios.

delimiter //
create trigger trg_log_permission_changes
after insert 
on cambios_permisos
for each row
begin
	insert into logs_permisos (usuario, permiso, accion)
	values (new.usuario, new.permiso, new.accion);
end //
delimiter ;

-- 19. trg_assign_default_category_on_null: Asigna una categoría "General" si se inserta un producto sin categoría.
insert into categorias(nombre) values
('General');

delimiter //
create trigger trg_assign_default_category_on_null
before insert 
on productos
for each row
begin
	declare v_categoria_general int;

	select id_categoria 
	into v_categoria_general 
	from categorias 
	where nombre = 'General';
	
	if new.categoria is null then 
		set new.categoria = v_categoria_general;
	end if ;
end //
delimiter ;

-- 20. trg_update_producto_count_in_categoria: Mantiene un contador de cuántos productos hay en cada categoría.
delimiter //
create trigger trg_update_producto_count_in_categoria
after insert 
on productos 
for each row 
begin
	update categorias
	set total_productos = (
		select count(*)
		from productos 
		where categoria = new.categoria
	)
	where id_categoria = new.categoria;
end //
delimiter

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
    DELETE FROM backup_clientes;
    DELETE FROM backup_productos;
    DELETE FROM backup_ventas;

    INSERT INTO backup_clientes SELECT * FROM clientes;
    INSERT INTO backup_productos SELECT * FROM productos;
    INSERT INTO backup_ventas SELECT * FROM ventas;
END;


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
delimiter

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
	where v.estado = 'estregado'
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

-- ===================================
-- PROCEDIMIENTOS ALMACENADOS
-- (Damian 1 - 5 / 11 - 15 -- Juan 6 - 10 / 16 - 20)
-- ====================================================

-- 1. Procesa una nueva venta de forma transaccional.

	CREATE PROCEDURE sp_RealizarNuevaVenta(IN p_id_cliente INT,IN p_id_producto INT,IN p_cantidad INT,IN p_id_sucursal INT)
	BEGIN
	    DECLARE v_precio DECIMAL(10,2);
	    DECLARE v_stock INT;
	    DECLARE v_id_venta INT;
	
	    START TRANSACTION;
	
	    SELECT precio, stock
	    INTO v_precio, v_stock
	    FROM productos
	    WHERE id_producto = p_id_producto;
	
	    IF v_stock >= p_cantidad THEN
	
	        INSERT INTO ventas(id_cliente, estado, total, id_sucursal)
	        VALUES (
	            p_id_cliente,
	            'procesando',
	            v_precio * p_cantidad,
	            p_id_sucursal
	        );
	
	        SET v_id_venta = LAST_INSERT_ID();
	
	        INSERT INTO detalle_ventas(
	            id_venta,
	            id_producto,
	            cantidad,
	            precio_unitario_congelado
	        )
	        VALUES (
	            v_id_venta,
	            p_id_producto,
	            p_cantidad,
	            v_precio
	        );
	
	        UPDATE productos
	        SET stock = stock - p_cantidad
	        WHERE id_producto = p_id_producto;
	
	        COMMIT;
	
	    ELSE
	        ROLLBACK;
	    END IF;
	END;
	    
	CALL sp_RealizarNuevaVenta(1, 1, 2, 1);
	
-- 2. Inserta un nuevo producto y sus atributos iniciales.
	
	CREATE PROCEDURE sp_AgregarNuevoProducto(
	    IN p_nombre VARCHAR(100),
	    IN p_descripcion VARCHAR(255),
	    IN p_categoria INT,
	    IN p_proveedor INT,
	    IN p_precio DECIMAL(10,2),
	    IN p_costo DECIMAL(10,2),
	    IN p_stock INT,
	    IN p_sku VARCHAR(20)
	)
	BEGIN
	    INSERT INTO productos(
	        nombre,
	        descripcion,
	        categoria,
	        proveedor,
	        precio,
	        costo,
	        stock,
	        sku,
	        activo
	    )
	    VALUES (
	        p_nombre,
	        p_descripcion,
	        p_categoria,
	        p_proveedor,
	        p_precio,
	        p_costo,
	        p_stock,
	        p_sku,
	        TRUE
	    );
	END;

	CALL sp_AgregarNuevoProducto('Abbey Road', 'The Beatles',1,1,200000,140000, 10,'VIN051');
	
-- 3. Actualiza la dirección de un cliente en todas las tablas relevantes.
	
	CREATE PROCEDURE sp_ActualizarDireccionCliente(
	    IN p_id_cliente INT,
	    IN p_nueva_direccion VARCHAR(100)
	)
	BEGIN
	    UPDATE clientes
	    SET direccion_envio = p_nueva_direccion
	    WHERE id_cliente = p_id_cliente;
	END;

	CALL sp_ActualizarDireccionCliente(1, 'Nueva dirección en Bogotá');
	
-- 4. Gestiona la devolución de un producto, ajustando el stock y generando un crédito.
	
	CREATE TABLE creditos_cliente (
    id_credito INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    valor_credito DECIMAL(10,2),
    fecha_credito TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	
CREATE PROCEDURE sp_ProcesarDevolucion(
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad INT)
	BEGIN
	    DECLARE v_id_cliente INT;
	    DECLARE v_precio DECIMAL(10,2);
	
	    SELECT id_cliente
	    INTO v_id_cliente
	    FROM ventas
	    WHERE id_venta = p_id_venta;
	
	    SELECT precio_unitario_congelado
	    INTO v_precio
	    FROM detalle_ventas
	    WHERE id_venta = p_id_venta
	      AND id_producto = p_id_producto
	    LIMIT 1;
	
	    UPDATE productos
	    SET stock = stock + p_cantidad
	    WHERE id_producto = p_id_producto;
	
	    INSERT INTO creditos_cliente(
	        id_cliente,
	        id_producto,
	        valor_credito
	    )
	    VALUES (
	        v_id_cliente,
	        p_id_producto,
	        v_precio * p_cantidad
	    );
	END;
	    
	CALL sp_ProcesarDevolucion(1, 1, 1);
	
-- 5. Devuelve el historial completo de compras de un cliente.
	
	CREATE PROCEDURE sp_ObtenerHistorialComprasCliente(
	    IN p_id_cliente INT
	)
	BEGIN
	    SELECT
	        v.id_venta,
	        DATE(v.fecha_venta) AS fecha,
	        v.estado,
	        p.nombre AS producto,
	        dv.cantidad,
	        dv.precio_unitario_congelado,
	        v.total
	    FROM ventas v
	    INNER JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
	    INNER JOIN productos p ON dv.id_producto = p.id_producto
	    WHERE v.id_cliente = p_id_cliente
	    ORDER BY v.fecha_venta DESC;
	END;
	
	CALL sp_ObtenerHistorialComprasCliente(1);
	
-- 11. Registra un nuevo cliente validando que el email no exista.
	
	CREATE PROCEDURE sp_RegistrarNuevoCliente(
	    IN p_nombre VARCHAR(50),
	    IN p_apellido VARCHAR(70),
	    IN p_email VARCHAR(100),
	    IN p_fecha_nacimiento DATE,
	    IN p_contrasena VARCHAR(200),
	    IN p_direccion_envio VARCHAR(100))
	BEGIN
	    IF EXISTS (
	        SELECT 1 
	        FROM clientes 
	        WHERE email = p_email
	    ) THEN
	        SELECT 'Ese email ya existe' AS mensaje;
	    ELSE
	        INSERT INTO clientes( nombre,apellido, email,fecha_nacimiento,contrasena, direccion_envio)
	        VALUES (p_nombre,  p_apellido,  p_email,p_fecha_nacimiento,p_contrasena,p_direccion_envio );
	        SELECT 'Cliente registrado correctamente' AS mensaje;
	    END IF;
	END;
	
	CALL sp_RegistrarNuevoCliente('Luis','Mendoza','luis@gmail.com', '1997-04-15', '123456','Bogotá' );
	
-- 12. Devuelve toda la información de un producto, incluyendo datos de su proveedor y categoría.
	
	CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto(IN p_id_producto INT)
	BEGIN
	    SELECT
	        p.id_producto,
	        p.nombre AS producto,
	        p.descripcion,
	        p.precio,
	        p.costo,
	        p.stock,
	        p.sku,
	        p.activo,
	        c.nombre AS categoria,
	        pr.nombre AS proveedor,
	        pr.email_contcto,
	        pr.telefono
	    FROM productos p
	    LEFT JOIN categorias c ON p.categoria = c.id_categoria
	    LEFT JOIN proveedores pr ON p.proveedor = pr.id_proveedor
	    WHERE p.id_producto = p_id_producto;
	END;
	
	CALL sp_ObtenerDetallesProductoCompleto(1);
	
-- 13. Fusiona dos cuentas de cliente duplicadas en una sola.
	
	CREATE PROCEDURE sp_FusionarCuentasCliente(
	    IN p_cliente_principal INT,
	    IN p_cliente_duplicado INT
	)
	BEGIN
	    UPDATE ventas
	    SET id_cliente = p_cliente_principal
	    WHERE id_cliente = p_cliente_duplicado;
	
	    DELETE FROM clientes
	    WHERE id_cliente = p_cliente_duplicado;
	
	    SELECT 'Cuentas fusionadas correctamente' AS mensaje;
	END;
	   
	CALL sp_FusionarCuentasCliente(1, 2);
	    
-- 14. Asigna o cambia el proveedor de un producto.
	    
	CREATE PROCEDURE sp_AsignarProductoAProveedor(
	    IN p_id_producto INT,
	    IN p_id_proveedor INT
	)
	BEGIN
	    UPDATE productos
	    SET proveedor = p_id_proveedor
	    WHERE id_producto = p_id_producto;
	
	    SELECT 'Listo calisto, proveedor actualizado' AS mensaje;
	END;
	   
	CALL sp_AsignarProductoAProveedor(1, 3);
	    
-- 15. Realiza una búsqueda avanzada de productos con filtros por nombre, categoría, rango de precios, etc.

CREATE PROCEDURE sp_BuscarProductos(
    IN p_nombre VARCHAR(100),
    IN p_categoria INT,
    IN p_precio_min DECIMAL(10,2),
    IN p_precio_max DECIMAL(10,2)
)
BEGIN
    SELECT
        p.id_producto,
        p.nombre,
        p.descripcion,
        c.nombre AS categoria,
        pr.nombre AS proveedor,
        p.precio,
        p.stock,
        p.sku
    FROM productos p
    LEFT JOIN categorias c ON p.categoria = c.id_categoria
    LEFT JOIN proveedores pr ON p.proveedor = pr.id_proveedor
    WHERE (p_nombre IS NULL OR p.nombre LIKE CONCAT('%', p_nombre, '%'))
      AND (p_categoria IS NULL OR p.categoria = p_categoria)
      AND (p_precio_min IS NULL OR p.precio >= p_precio_min)
      AND (p_precio_max IS NULL OR p.precio <= p_precio_max);
END;

CALL sp_BuscarProductos('Pink', NULL, 100000, 200000);