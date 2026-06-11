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
	email_contacto VARCHAR(100) UNIQUE,
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
    nombre VARCHAR(50),
    apellido VARCHAR(70),
    email VARCHAR(100) UNIQUE,
    fecha_nacimiento DATE,
    contrasena VARCHAR(200) NOT NULL,
    direccion_envio VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
);

CREATE TABLE intentos_login (
    id_intento INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    ip varchar(50),
    fecha_intento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    exitoso enum('exitoso', 'fallido')
);

CREATE TABLE logs_permisos (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    permiso VARCHAR(100),
    accion ENUM('GRANT','REVOKE'),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cambios_permisos (
    id_cambio INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    permiso VARCHAR(100),
    accion ENUM('GRANT','REVOKE'),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table lista_reabastecimiento(
	id_producto int primary key,
	nombre varchar(100),
	stock_actual int,
	fecha_generacion timestamp default current_timestamp
);

create table ventas_diarias(
	id_venta int primary key,
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
	id_proveedor int primary key,
	proveedor varchar(100),
	total_ventas decimal(12,2),
	unidades_vendidas int,
	pedidos_participados int,
	fecha_reporte date
);

create table actualizacion_stock_m(
	id_actualizacion int auto_increment primary key,
	id_producto int,
	stock_anterior int,
	nuevo_stock int,
	motivo varchar(255),
	fecha_actualizacion timestamp default current_timestamp
);

create table  notificaciones_pedidos(
	id_notificacion int auto_increment primary key,
	id_venta int,
	estado_anterior varchar(100),
	nuevo_estado varchar(100),
	fecha_notificacion timestamp default current_timestamp
);

create table resenas_productos (
	id_resena int auto_increment primary key,
	id_producto int,
	id_cliente int,
	calificacion int,
	comentario varchar(255),
	fecha timestamp default current_timestamp
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
