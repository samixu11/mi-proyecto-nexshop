-- =============================================================================
--  NexShop Group S.A.  |  consultas.sql
--  Bateria de consultas. Ejecutar tras schema.sql + datos.sql.
--  Cada consulta lleva un comentario de una linea con que devuelve y para que sirve.
--  Las consultas 1-14 cubren las tecnicas obligatorias del enunciado.
--  Las 15-19 anaden LEFT JOIN, agregaciones, subconsultas y uso de vista
--  (criterios de evaluacion B y C).
--  Autor: Erik Mora
-- =============================================================================

USE nexshop;

-- 1) Lista completa de la plantilla: todos los empleados de NexShop.
SELECT * FROM empleado;

-- 2) Datos de contacto de los clientes REGISTRADOS (email no nulo) para campanas.
SELECT nombre, apellidos, email
FROM cliente
WHERE email IS NOT NULL;

-- 3) Pedidos que siguen pendientes de procesar (filtro exacto por estado).
SELECT *
FROM pedido
WHERE estado = 'pendiente';

-- 4) Buscar en el catalogo todos los portatiles (patron LIKE en el nombre).
SELECT id_producto, nombre, pvp
FROM producto
WHERE nombre LIKE '%Portatil%';

-- 5) Clientes cuyo nombre empieza por 'A' (LIKE con patron inicial).
SELECT nombre, apellidos
FROM cliente
WHERE nombre LIKE 'A%';

-- 6) Pedidos realizados en el primer semestre de 2025 (rango de fechas BETWEEN).
SELECT id_pedido, fecha_pedido, estado
FROM pedido
WHERE fecha_pedido BETWEEN '2025-01-01' AND '2025-06-30';

-- 7) Productos de precio medio: PVP entre 100 y 500 EUR (rango numerico BETWEEN).
SELECT id_producto, nombre, pvp
FROM producto
WHERE pvp BETWEEN 100 AND 500;

-- 8) Lineas de pedido con cantidad > 1 (condicion numerica) cruzando con el nombre del producto.
SELECT lp.id_pedido, p.nombre, lp.cantidad
FROM linea_pedido lp
JOIN producto p ON p.id_producto = lp.id_producto
WHERE lp.cantidad > 1;

-- 9) Pedidos ordenados del mas antiguo al mas reciente (ORDER BY ascendente).
SELECT id_pedido, fecha_pedido, estado
FROM pedido
ORDER BY fecha_pedido ASC;

-- 10) Productos ordenados de mayor a menor PVP (ORDER BY descendente).
SELECT nombre, pvp
FROM producto
ORDER BY pvp DESC;

-- 11) Clientes ordenados alfabeticamente por apellidos y nombre (ORDER BY texto).
SELECT nombre, apellidos
FROM cliente
ORDER BY apellidos ASC, nombre ASC;

-- 12) Marcar como 'enviado' un pedido concreto (UPDATE de un registro especifico).
UPDATE pedido
SET estado = 'enviado'
WHERE id_pedido = 3;

-- 13) Actualizar el telefono de un cliente identificandolo por su id (UPDATE con WHERE).
UPDATE cliente
SET telefono = '600000999'
WHERE id_cliente = 2;

-- 14) Mostrar cada pedido junto con el nombre de su cliente (JOIN de dos tablas).
SELECT c.nombre, c.apellidos, pe.id_pedido, pe.fecha_pedido, pe.estado
FROM cliente c
JOIN pedido pe ON pe.id_cliente = c.id_cliente
ORDER BY c.apellidos;

-- =============================================================================
--  Consultas adicionales (criterios B y C: LEFT JOIN, agregaciones, subconsultas, vista)
-- =============================================================================

-- 15) Numero de pedidos por cliente INCLUYENDO los que no han comprado (LEFT JOIN + COUNT).
SELECT c.id_cliente, c.nombre, c.apellidos, COUNT(pe.id_pedido) AS num_pedidos
FROM cliente c
LEFT JOIN pedido pe ON pe.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY num_pedidos DESC, c.apellidos;

-- 16) Facturacion online por producto (agregacion SUM con descuento aplicado).
SELECT p.id_producto, p.nombre,
       SUM(lp.cantidad * lp.precio_unitario * (1 - lp.descuento_pct/100)) AS total_facturado
FROM linea_pedido lp
JOIN producto p ON p.id_producto = lp.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY total_facturado DESC;

-- 17) Productos cuyo PVP supera la media del catalogo (subconsulta escalar).
SELECT nombre, pvp
FROM producto
WHERE pvp > (SELECT AVG(pvp) FROM producto)
ORDER BY pvp DESC;

-- 18) Saldo de puntos de fidelizacion de los clientes con puntos (uso de la VISTA v_saldo_puntos).
SELECT id_cliente, nombre, apellidos, saldo_puntos
FROM v_saldo_puntos
WHERE saldo_puntos > 0
ORDER BY saldo_puntos DESC;

-- 19) Clientes registrados que nunca han dejado una valoracion (subconsulta con NOT IN).
SELECT nombre, apellidos
FROM cliente
WHERE email IS NOT NULL
  AND id_cliente NOT IN (SELECT id_cliente FROM valoracion);

-- =============================================================================
-- FIN consultas.sql
-- =============================================================================
