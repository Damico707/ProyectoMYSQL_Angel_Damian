-- //////// TALLER DE PRACTICA //////////

SELECT dv1.id_producto AS vinilo1 ,dv2.id_producto   AS vinilo2
FROM detalle_ventas dv1
JOIN detalle_ventas dv2 ON dv1.id_venta = dv2.id_venta
GROUP BY vinilo1 , vinilo2 
-- primero GROUP BY y ya luego count para no perder las veces que se agruparon


-- 2. Cuente cuántas veces ha ocurrido cada par.

SELECT dv1.id_producto AS vinilo1 ,dv2.id_producto   AS vinilo2, COUNT(*) AS pares
FROM detalle_ventas dv1
JOIN detalle_ventas dv2 ON dv1.id_venta = dv2.id_venta
GROUP BY vinilo1 , vinilo2 
HAVING COUNT(*) >=2
ORDER BY pares DESC;


-- 3. Devuelva una lista con los nombres de ambos productos y el número de veces que
-- se han comprado juntos, ordenada de mayor a menor frecuencia. y punto 4 evitar duplicados

SELECT p1.nombre AS vinilo1 ,p2.nombre  AS vinilo2, COUNT(*) AS pares  -- Cuenta cuantas veces se repetia cada fila despues que le añadimos group by para que las filas no se repitiesen
FROM detalle_ventas dv1
JOIN detalle_ventas dv2 ON dv1.id_venta = dv2.id_venta AND dv1.id_producto < dv2.id_producto
JOIN productos p1 ON p1.id_producto = dv1.id_producto
JOIN productos p2 ON p2.id_producto = dv2.id_producto
GROUP BY vinilo1 , vinilo2 
HAVING COUNT(*) >=2
ORDER BY pares DESC;