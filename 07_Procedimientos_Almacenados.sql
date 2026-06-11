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

    -- 6. sp_AjustarNivelStock: Permite ajustar manualmente el stock de un producto, registrando el motivo.
delimiter //
create procedure sp_AjustarNivelStock(in p_id_producto int, in p_nuevo_stock int, in p_motivo varchar(255))
begin 
	
	declare v_stock_old int;
	
	if exists(
		select 1
		from productos 
		where id_producto = p_id_producto
	) then
		
		select stock 
		into v_stock_old 
		from productos 
		where id_producto = p_id_producto;	
	
		if p_nuevo_stock < 0 then
			signal sqlstate '45000'
			set message_text = 'El stock no puede ser negativo';
		else 
			update productos 
			set stock = p_nuevo_stock
			where id_producto = p_id_producto;

			insert into actualizacion_stock_m (id_producto, stock_anterior, nuevo_stock, motivo) values
			(p_id_producto, v_stock_old, p_nuevo_stock, p_motivo);
		
		end if;
	else 
		signal sqlstate '45000'
		set message_text = 'Producto no encontrado';
	end if;
end //
delimiter ;

call sp_AjustarNivelStock(2, 14, 'Mal calculo al momento de recibir el producto');

-- 7. sp_EliminarClienteDeFormaSegura: Anonimiza los datos de un cliente en lugar de borrarlos, para mantener la integridad referencial.
delimiter //
create procedure sp_EliminarClienteDeFormaSegura(in p_id_cliente int)
begin 
	if exists(
		select 1
		from clientes 
		where id_cliente = p_id_cliente
	) then
		update clientes
			set nombre = 'ANONIMO',
				apellido = 'ANONIMO',
				email = concat('anonimo_', id_cliente, '@deleted.com'),
				direccion_envio = null,
				contrasena = sha2(uuid(),256)
		where id_cliente = p_id_cliente;
	else 
		signal sqlstate '45000'
		set message_text = 'Cliente no encontrado';
	end if;
end // 
delimiter ;

call sp_EliminarClienteDeFormaSegura(16);

-- 8. sp_AplicarDescuentoPorCategoria: Aplica un descuento a todos los productos de una categoría específica.
delimiter //
create procedure sp_AplicarDescuentoPorCategoria(in p_categoria varchar(100), in p_descuento decimal(5,2))
begin 
	declare v_id_categoria int;
	select id_categoria
	into v_id_categoria
	from categorias
	where nombre = p_categoria;

	if v_id_categoria is not null then

		update productos 
		set precio = precio * (1 - p_descuento / 100)
		where categoria = v_id_categoria;
	else 
		signal sqlstate '45000'
		set message_text = 'Categoria no encontrada';
	end if;	
end // 
delimiter ;

call sp_AplicarDescuentoPorCategoria('Jazz', 20);

-- 9. sp_GenerarReporteMensualVentas: Genera un reporte completo de ventas para un mes y año dados.
delimiter //
create procedure sp_GenerarReporteMensualVentas(in p_mes int, in p_anio int)
begin 
	select 
		count(*) as cantidad_pedidos,
		sum(total) as ventas_totales,
		avg(total) as promedio_por_pedido,
		count(distinct id_cliente) as clientes_unicos
	from ventas 
	where month(fecha_venta) = p_mes
		and year(fecha_venta) = p_anio
		and estado = 'entregado';	
end //
delimiter ;

call sp_GenerarReporteMensualVentas(4, 2025);

-- 10. sp_CambiarEstadoPedido: Cambia el estado de un pedido (ej. 'Procesando' a 'Enviado') y notifica a otros sistemas.

delimiter //
create procedure sp_CambiarEstadoPedido(in p_id_venta int, in p_nuevo_estado varchar(100))
begin 
	declare v_estado_actual varchar(100);

	if p_nuevo_estado not in ( 'pendiente_pago', 'procesando', 'enviado', 'entregado', 'cancelado') then
			signal sqlstate '45000'
			set message_text = 'Estado no valido';
	else
		if exists (
			select 1 
			from ventas
			where id_venta = p_id_venta
		) then 
			select estado 
			into v_estado_actual 
			from ventas
			where id_venta = p_id_venta;
			
			if v_estado_actual = p_nuevo_estado then
				signal sqlstate '45000'
				set message_text = 'Estado Actualizado';
			else
				update ventas 
				set estado = p_nuevo_estado
				where id_venta = p_id_venta;
	
				insert into notificaciones_pedidos (id_venta, estado_anterior, nuevo_estado) values
				(p_id_venta, v_estado_actual, p_nuevo_estado);
			end if;
		else 
			signal sqlstate '45000'
			set message_text = 'Venta no encontrada';
		end if;	
	end if;
end //
delimiter ;

call sp_CambiarEstadoPedido(3, 'enviado');
	
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

-- 16. sp_ObtenerDashboardAdmin: Devuelve un conjunto de KPIs para un panel de administración (ventas de hoy, nuevos clientes, etc.).
delimiter //
create procedure sp_ObtenerDashboardAdmin()
begin
	-- pedidos hoy
	select
		(
			select 
				count(*) 
			from ventas
			where date(fecha_venta) = curdate() 
			 and estado = 'entregado'
		) as pedido_hoy,
		
		-- nuevos clientes
		(	
			select
				count(*)
			from clientes 
			where date(fecha_registro) = curdate() 
		) as nuevos_clientes,
			
		-- productos activos
		(
			select 
				count(*) 
			from productos 
			where activo = true
		) as productos_activos,
		
		-- bajo stock
		(
			select 
				count(*) 
			from productos 
			where stock < 8
		) as stock_bajo,
		
		-- ventas hoy
		(
			select 
				coalesce(sum(total),0)
			from ventas 
			where date(fecha_venta) = curdate() 
			 and estado = 'entregado'
		) as ventas_hoy;
end //
delimiter ;
CALL sp_ObtenerDashboardAdmin();

-- 17. sp_ProcesarPago: Simula el procesamiento de un pago para una venta, actualizando su estado a "Pagado".

delimiter //
create procedure sp_procesarpago(in p_id_venta int)
begin
	declare v_estado varchar(50);

	if exists (
		select 1
		from ventas
		where id_venta = p_id_venta
	) then

		select estado
		into v_estado
		from ventas
		where id_venta = p_id_venta;

		if v_estado = 'cancelado' then
			signal sqlstate '45000'
			set message_text = 'no se puede procesar un pago para una venta cancelada';

		elseif v_estado = 'enviado' then
			signal sqlstate '45000'
			set message_text = 'la venta ya fue pagada';

		else
			update ventas
			set estado = 'enviado'
			where id_venta = p_id_venta;

		end if;

	else
		signal sqlstate '45000'
		set message_text = 'venta no encontrada';

	end if;

end //

delimiter ;

call sp_procesarpago(10);

-- 18. sp_AñadirReseñaProducto: Permite a un cliente añadir una reseña y calificación a un producto que ha comprado.

delimiter //
create procedure sp_añadirreseñaproducto(in p_id_producto int, in p_id_cliente int,	in p_calificacion int, in p_comentario varchar(255))
begin

	if exists (
		select 1
		from ventas v
		join detalle_ventas dv on v.id_venta = dv.id_venta
		where v.id_cliente = p_id_cliente
		  and dv.id_producto = p_id_producto
		  and v.estado = 'entregado'
	) then

		insert into resenas_productos (
			id_producto,
			id_cliente,
			calificacion,
			comentario
		)
		values (
			p_id_producto,
			p_id_cliente,
			p_calificacion,
			p_comentario
		);

	else
		signal sqlstate '45000'
		set message_text = 'el cliente no ha comprado este producto';

	end if;

end //

delimiter ;


call sp_añadirreseñaproducto(1, 1, 5, 'excelente producto, lo recomiendo');

-- 19. sp_ObtenerProductosRelacionados: Devuelve una lista de productos relacionados a uno dado, basándose en compras de otros clientes.
delimiter //
create procedure sp_obtenerproductosrelacionados(in p_id_producto int)
begin
	select 
		p.id_producto,
		p.nombre,
		count(*) as frecuencia
	from detalle_ventas dv1
	join ventas v1 on dv1.id_venta = v1.id_venta
	join detalle_ventas dv2 on v1.id_venta = dv2.id_venta
	join productos p on dv2.id_producto = p.id_producto
	where dv1.id_producto = p_id_producto
	  and dv2.id_producto <> p_id_producto
	group by p.id_producto, p.nombre
	order by frecuencia desc;

end //

delimiter ;

call sp_obtenerproductosrelacionados(1);

-- 20. sp_MoverProductosEntreCategorias: Mueve uno o más productos de una categoría a otra de forma segura.
delimiter //
create procedure sp_moverproductoscategorias(in p_categoria_origen int, in p_categoria_destino int)
begin
	if exists (
		select 1 from categorias where id_categoria = p_categoria_origen
	) and exists (
		select 1 from categorias where id_categoria = p_categoria_destino
	) then

		update productos
		set categoria = p_categoria_destino
		where categoria = p_categoria_origen;

	else
		signal sqlstate '45000'
		set message_text = 'categoria origen o destino no existe';

	end if;

end //

delimiter ;

call sp_moverproductoscategorias(1, 3);