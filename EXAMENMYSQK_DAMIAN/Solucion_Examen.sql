-- /// solucion examen ///

-- trg_audit_cliente_after_update que se dispare después de que se actualice un registro en la tabla Clientes.



-- Primero, crea una tabla de auditoría llamada Auditoria_Clientes con campos como id_auditoria, id_cliente, campo_modificado, valor_antiguo, valor_nuevo y fecha_modificacion.
-- El trigger debe activarse solo si el valor del campo email o direccion_envio ha cambiado.
-- Cuando se dispare, el trigger debe insertar un nuevo registro en la tabla Auditoria_Clientes, almacenando el valor antiguo y el nuevo del campo que fue modificado.

CREATE TABLE auditoria_Clientes_examen (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	id_cliente INT NOT NULL,
	campo_modificado VARCHAR(100),
	valor_antiguo VARCHAR (100),
	valor_nuevo VARCHAR(100),
	fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TRIGGER trg_audit_cliente_after_update_examen_email
AFTER UPDATE ON clientes
FOR EACH ROW 
BEGIN 
	
	IF NEW.email<> OLD.email THEN  -- si el nuevo email ingresado es diferente al valor antiguo se inserta en la tabla
		INSERT INTO auditoria_Clientes_examen(id_cliente,campo_modificado,valor_antiguo,valor_nuevo) 
		VALUES (NEW.id_cliente,'email',OLD.email,NEW.email);
	END IF;
		
	IF NEW.direccion_envio <> OLD.direccion_envio THEN -- lo mismo del email pero con la direccion
		INSERT INTO auditoria_Clientes_examen(id_cliente,campo_modificado,valor_antiguo,valor_nuevo) 
		VALUES (NEW.id_cliente,'direccion_envio',OLD.direccion_envio,NEW.direccion_envio);  -- insertar valores en la tabla auditoria
	END IF;
END;


UPDATE clientes
SET email = 'prueba707@gmail.com'  -- prueba para verificar el cambio y insersion en la tabla de auditoria
WHERE id_cliente= 1;

UPDATE clientes
SET direccion_envio  = 'cucutant'  -- prueba para verificar el cambio y insersion en la tabla de auditoria
WHERE id_cliente= 1;
