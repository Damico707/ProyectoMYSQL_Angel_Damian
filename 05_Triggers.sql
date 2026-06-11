
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
	AFTER INSERT ON detalle_ventas
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
after insert 
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