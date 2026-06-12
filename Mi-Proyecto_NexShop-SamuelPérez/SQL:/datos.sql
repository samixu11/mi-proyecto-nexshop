-- =============================================================================
--  NexShop Group S.A.  |  datos.sql
--  Datos de prueba realistas. Ejecutar DESPUES de schema.sql.
--  Incluye: NULLs deliberados, estados variados, un pedido con varios envios,
--  ventas presenciales anonimas y vinculadas, valoraciones verificadas y no,
--  e historicos de precio / suministro / puntos.
--  Autor: Samuel Pérez-Herrero Soler
-- =============================================================================

USE nexshop;

-- ----------------------------------------------------------------------------
-- Catalogo
-- ----------------------------------------------------------------------------
INSERT INTO categoria (id_categoria, nombre) VALUES
 (1,'Informatica'), (2,'Hogar'), (3,'Telefonia'), (4,'Audio');

INSERT INTO subcategoria (id_subcategoria, nombre, id_categoria) VALUES
 (1,'Portatiles',1), (2,'Monitores',1), (3,'Perifericos',1),
 (4,'Smartphones',3), (5,'Auriculares',4), (6,'Pequeno electrodomestico',2);

INSERT INTO producto (id_producto, nombre, descripcion, pvp, id_subcategoria, activo) VALUES
 (1,'Portatil Gaming NexBook 15','Portatil gaming 15 pulgadas RTX', 1299.00, 1, TRUE),
 (2,'Portatil Oficina NexBook Pro 14','Portatil para oficina ligero',  899.00, 1, TRUE),
 (3,'Portatil Ultraligero NexAir 13','Ultraligero 13 pulgadas',       1099.00, 1, TRUE),
 (4,'Monitor NexView 27 4K','Monitor 27 pulgadas 4K',                  349.00, 2, TRUE),
 (5,'Monitor NexView 24 FHD','Monitor 24 pulgadas Full HD',            159.00, 2, TRUE),
 (6,'Teclado mecanico NexKey','Teclado mecanico retroiluminado',        79.99, 3, TRUE),
 (7,'Raton inalambrico NexMouse','Raton inalambrico ergonomico',        29.99, 3, TRUE),
 (8,'Smartphone NexPhone X','Smartphone gama alta',                    699.00, 4, TRUE),
 (9,'Smartphone NexPhone Lite','Smartphone gama media',                249.00, 4, TRUE),
 (10,'Auriculares NexSound Pro','Auriculares con cancelacion ruido',   199.00, 5, TRUE),
 (11,'Auriculares NexSound Air','Auriculares inalambricos basicos',     89.00, 5, TRUE),
 (12,'Cafetera NexCoffee','Cafetera de capsulas',                      119.00, 6, FALSE);

-- Historico de PVP: producto 1 ha cambiado de precio; producto 4 tambien.
INSERT INTO historico_precio (id_producto, precio, fecha_inicio, fecha_fin) VALUES
 (1, 1399.00, '2024-01-01', '2024-12-31'),
 (1, 1299.00, '2025-01-01', NULL),
 (4,  379.00, '2024-06-01', '2025-02-28'),
 (4,  349.00, '2025-03-01', NULL),
 (8,  699.00, '2025-01-01', NULL);

-- ----------------------------------------------------------------------------
-- Promociones (N:M con producto)
-- ----------------------------------------------------------------------------
INSERT INTO promocion (id_promocion, nombre, descuento_pct, fecha_inicio, fecha_fin) VALUES
 (1,'Rebajas de invierno',     15.00, '2025-01-07', '2025-01-31'),
 (2,'Vuelta al cole',          10.00, '2025-09-01', '2025-09-15'),
 (3,'Black Friday 2024',       25.00, '2024-11-29', '2024-11-30');

INSERT INTO promocion_producto (id_promocion, id_producto) VALUES
 (1,4), (1,5), (1,1),
 (2,2), (2,6),
 (3,1), (3,8), (3,10);

-- ----------------------------------------------------------------------------
-- Ubicaciones
-- ----------------------------------------------------------------------------
INSERT INTO ubicacion (id_ubicacion, nombre, tipo, ciudad, direccion) VALUES
 (1,'Almacen Central','almacen','Valencia','Poligono Industrial Norte, Nave 4'),
 (2,'Tienda Valencia','tienda','Valencia','Calle Colon 22'),
 (3,'Tienda Madrid','tienda','Madrid','Gran Via 15'),
 (4,'Tienda Barcelona','tienda','Barcelona','Passeig de Gracia 80');

-- ----------------------------------------------------------------------------
-- Empleados
-- ----------------------------------------------------------------------------
INSERT INTO empleado (id_empleado, nombre, apellidos, dni, email_corporativo, fecha_incorporacion, puesto, id_ubicacion) VALUES
 (1,'Ana','Ferrer','11111111A','a.ferrer@nexshop.es','2015-09-01','direccion',1),
 (2,'David','Cano','22222222B','d.cano@nexshop.es','2016-03-15','logistica',1),
 (3,'Laura','Pons','33333333C','l.pons@nexshop.es','2017-01-10','atencion_cliente',1),
 (4,'Sergio','Blanco','44444444D','s.blanco@nexshop.es','2018-06-20','it',1),
 (5,'Marta','Gil','55555555E','m.gil@nexshop.es','2019-02-01','compras',1),
 (6,'Carlos','Ruiz','66666666F','c.ruiz@nexshop.es','2019-09-12','comercial',1),
 (7,'Lucia','Marti','77777777G','lu.marti@nexshop.es','2018-04-05','encargado',2),
 (8,'Pedro','Sanz','88888888H','p.sanz@nexshop.es','2020-05-18','vendedor',2),
 (9,'Elena','Vidal','99999999I','e.vidal@nexshop.es','2021-07-22','vendedor',2),
 (10,'Jorge','Ramos','10101010J','j.ramos@nexshop.es','2019-11-03','responsable_almacen',2),
 (11,'Nuria','Soler','12121212K','n.soler@nexshop.es','2018-08-14','encargado',3),
 (12,'Ivan','Torres','13131313L','i.torres@nexshop.es','2022-01-09','vendedor',3),
 (13,'Sara','Mora','14141414M','sa.mora@nexshop.es','2020-10-01','responsable_almacen',3),
 (14,'Hugo','Leon','15151515N','h.leon@nexshop.es','2017-05-30','encargado',4),
 (15,'Clara','Diaz','16161616O','c.diaz@nexshop.es','2021-03-17','vendedor',4),
 (16,'Raul','Ortega','17171717P','r.ortega@nexshop.es','2022-09-05','atencion_cliente',1);

-- ----------------------------------------------------------------------------
-- Proveedores (representante = empleado comercial id 6; uno sin representante)
-- ----------------------------------------------------------------------------
INSERT INTO proveedor (id_proveedor, nombre, cif, email, telefono, id_representante) VALUES
 (1,'TecnoDistribuciones SL','B12345678','ventas@tecnodist.es','961000001',6),
 (2,'GlobalParts SA','A87654321','contacto@globalparts.com','911000002',6),
 (3,'AudioImport SL','B11223344','info@audioimport.es','931000003',6),
 (4,'HogarPlus SL','B55667788','pedidos@hogarplus.es','961000004',NULL);

-- Suministros: historico de condiciones producto-proveedor (vigente = fecha_fin NULL)
INSERT INTO suministro (id_producto, id_proveedor, precio_coste, plazo_entrega_dias, fecha_inicio, fecha_fin) VALUES
 (1,1, 980.00, 7, '2024-01-01','2024-12-31'),   -- condicion antigua
 (1,1, 950.00, 5, '2025-01-01', NULL),          -- condicion vigente
 (1,2, 990.00,10, '2025-03-01', NULL),          -- segundo proveedor del mismo producto
 (2,1, 650.00, 6, '2025-01-01', NULL),
 (4,1, 240.00, 7, '2025-01-01', NULL),
 (5,1, 110.00, 7, '2025-01-01', NULL),
 (8,2, 520.00,12, '2025-01-01', NULL),
 (9,2, 180.00,12, '2025-01-01', NULL),
 (10,3,130.00, 9, '2025-01-01', NULL),
 (11,3, 55.00, 9, '2025-01-01', NULL),
 (12,4, 80.00,14, '2025-01-01', NULL);

-- ----------------------------------------------------------------------------
-- Clientes (cliente 7 sin email: pendiente de registro online / presencial)
-- ----------------------------------------------------------------------------
INSERT INTO cliente (id_cliente, nombre, apellidos, email, password_hash, telefono, fecha_nacimiento, fecha_registro) VALUES
 (1,'Ana','Lopez','ana.lopez@email.com','$2y$hash1','600111222','1990-05-12','2024-10-01 10:00:00'),
 (2,'Bruno','Marti','bruno.marti@email.com','$2y$hash2','600222333','1985-11-03','2024-11-15 12:30:00'),
 (3,'Carla','Sanz','carla.sanz@email.com','$2y$hash3','600333444','1998-07-21','2025-01-20 09:15:00'),
 (4,'Diego','Ramos','diego.ramos@email.com','$2y$hash4','600444555','1979-02-28','2025-02-05 18:45:00'),
 (5,'Elena','Ruiz','elena.ruiz@email.com','$2y$hash5','600555666','2000-12-15','2025-03-10 11:20:00'),
 (6,'Alberto','Gomez','alberto.gomez@email.com','$2y$hash6','600666777',NULL,'2025-04-01 16:00:00'),
 (7,'Gloria','Pena',NULL,NULL,'600777888',NULL,'2025-06-01 13:00:00');

-- Direcciones
INSERT INTO direccion (id_direccion, id_cliente, tipo, calle, numero, piso, codigo_postal, ciudad, pais) VALUES
 (1,1,'domicilio','Avenida del Puerto','45','3B','46023','Valencia','Espana'),
 (2,1,'trabajo','Calle Xativa','10',NULL,'46002','Valencia','Espana'),
 (3,2,'domicilio','Calle Alcala','200','5A','28028','Madrid','Espana'),
 (4,3,'domicilio','Carrer de Mallorca','150','2','08036','Barcelona','Espana'),
 (5,3,'otra','Rambla Catalunya','50',NULL,'08007','Barcelona','Espana'),
 (6,4,'domicilio','Calle Ruzafa','8','1A','46004','Valencia','Espana'),
 (7,5,'domicilio','Paseo de la Castellana','120','4C','28046','Madrid','Espana'),
 (8,6,'domicilio','Avenida de la Constitucion','30',NULL,'41001','Sevilla','Espana');

-- ----------------------------------------------------------------------------
-- Pedidos online (estados y fechas variados, incluido cancelado)
-- ----------------------------------------------------------------------------
INSERT INTO pedido (id_pedido, id_cliente, id_direccion, fecha_pedido, estado) VALUES
 (1,1,1,'2025-01-15 10:30:00','entregado'),
 (2,1,2,'2025-03-02 17:10:00','enviado'),
 (3,2,3,'2025-02-10 09:00:00','pendiente'),
 (4,3,4,'2024-11-20 20:05:00','entregado'),
 (5,4,6,'2025-05-05 14:25:00','pagado'),
 (6,5,7,'2025-06-01 08:45:00','pendiente'),
 (7,1,1,'2024-12-12 19:00:00','cancelado'),
 (8,6,8,'2025-04-18 12:00:00','entregado');

INSERT INTO linea_pedido (id_pedido, id_producto, cantidad, precio_unitario, descuento_pct) VALUES
 (1,1,1,1299.00,0),
 (1,7,2,29.99,0),
 (2,4,2,349.00,15.00),
 (3,8,1,699.00,0),
 (3,11,1,89.00,0),
 (4,5,3,159.00,0),
 (5,2,1,899.00,0),
 (5,6,1,79.99,0),
 (6,9,1,249.00,0),
 (7,10,1,199.00,0),
 (8,12,2,119.00,0),
 (8,7,1,29.99,0);

-- Envios: el pedido 1 se divide en DOS envios desde ubicaciones distintas.
INSERT INTO envio (id_envio, id_pedido, id_ubicacion_origen, tipo, numero_seguimiento, transportista, fecha_estimada, fecha_envio, estado) VALUES
 (1,1,1,'entrega','NS1001','SEUR','2025-01-18','2025-01-16','entregado'),
 (2,1,2,'entrega','NS1002','MRW','2025-01-19','2025-01-16','entregado'),
 (3,2,1,'entrega','NS1003','SEUR','2025-03-05','2025-03-03','en_transito'),
 (4,4,1,'entrega','NS1004','Correos','2024-11-23','2024-11-21','entregado'),
 (5,8,1,'entrega','NS1005','SEUR','2025-04-21','2025-04-19','entregado'),
 (6,4,4,'recogida','NS1006','SEUR','2025-04-17',NULL,'preparando');

INSERT INTO linea_envio (id_envio, id_producto, cantidad) VALUES
 (1,1,1),
 (2,7,2),
 (3,4,2),
 (4,5,3),
 (5,12,2),
 (5,7,1),
 (6,5,1);

-- ----------------------------------------------------------------------------
-- Ventas presenciales (ticket 1,2,4 anonimos; 3 y 5 vinculados a cliente)
-- ticket 5 ejemplifica una venta presencial vinculada a la cuenta del cliente 7.
-- ----------------------------------------------------------------------------
INSERT INTO ticket_venta (id_ticket_venta, id_ubicacion, id_empleado, id_cliente, fecha_hora) VALUES
 (1,2,8,NULL,'2025-02-01 11:00:00'),
 (2,3,12,NULL,'2025-03-10 16:30:00'),
 (3,2,9,1,'2025-04-02 18:00:00'),
 (4,4,15,NULL,'2025-05-20 12:15:00'),
 (5,2,8,7,'2025-06-02 10:45:00');

INSERT INTO linea_ticket_venta (id_ticket_venta, id_producto, cantidad, precio_unitario) VALUES
 (1,6,1,79.99),
 (1,7,1,29.99),
 (2,9,1,249.00),
 (3,11,2,89.00),
 (4,5,1,159.00),
 (5,12,1,119.00);

-- Devolucion presencial vinculada al ticket 1
INSERT INTO devolucion (id_devolucion, id_ticket_venta, id_empleado, fecha, motivo) VALUES
 (1,1,8,'2025-02-05 17:00:00','Producto defectuoso');
INSERT INTO linea_devolucion (id_devolucion, id_producto, cantidad) VALUES
 (1,7,1);

-- ----------------------------------------------------------------------------
-- Incidencias de atencion al cliente (estados variados, una devolucion online)
-- ----------------------------------------------------------------------------
INSERT INTO incidencia (id_incidencia, asunto, descripcion, fecha_apertura, estado, tipo, id_empleado, id_cliente, id_pedido, fecha_cierre, nota_resolucion) VALUES
 (1,'Pedido no recibido','El cliente indica que no ha recibido el envio','2025-03-05 09:30:00','en_gestion','queja',3,1,2,NULL,NULL),
 (2,'Consulta sobre garantia','Pregunta por la garantia del smartphone','2025-04-10 10:00:00','resuelto','consulta',16,3,NULL,'2025-04-11 12:00:00','Informado: 2 anos de garantia legal'),
 (3,'Devolucion online monitor','Solicita devolver el monitor del pedido 4','2025-04-15 13:00:00','en_gestion','devolucion_online',3,3,4,NULL,NULL),
 (4,'Pregunta sobre disponibilidad','Consulta general, cliente no identificado','2025-06-03 11:00:00','abierto','consulta',16,NULL,NULL,NULL,NULL);

-- ----------------------------------------------------------------------------
-- Stock por ubicacion (incluye un 0 deliberado)
-- ----------------------------------------------------------------------------
INSERT INTO stock (id_ubicacion, id_producto, cantidad) VALUES
 (1,1,25),(1,2,30),(1,3,15),(1,4,40),(1,5,50),(1,6,60),(1,7,100),(1,8,35),(1,9,45),(1,10,20),(1,11,55),(1,12,18),
 (2,1,5),(2,4,8),(2,5,12),(2,6,20),(2,7,30),(2,11,10),(2,12,0),
 (3,4,6),(3,5,9),(3,9,7),(3,11,5),
 (4,5,4),(4,8,3),(4,10,6),(4,12,2);

-- ----------------------------------------------------------------------------
-- Transferencias internas (origen != destino)
-- ----------------------------------------------------------------------------
INSERT INTO transferencia (id_transferencia, fecha, id_ubicacion_origen, id_ubicacion_destino, id_producto, cantidad, id_empleado) VALUES
 (1,'2025-03-01 09:00:00',1,3,4,5,2),
 (2,'2025-05-10 11:30:00',1,4,12,10,2);

-- ----------------------------------------------------------------------------
-- Valoraciones (verificadas y no verificadas; una por cliente-producto)
-- ----------------------------------------------------------------------------
INSERT INTO valoracion (id_valoracion, id_cliente, id_producto, puntuacion, comentario, fecha, verificada) VALUES
 (1,1,1,5,'Excelente portatil, muy rapido','2025-01-25 19:00:00',TRUE),
 (2,1,7,4,'Buen raton, comodo','2025-02-02 20:00:00',TRUE),
 (3,2,8,3,'Correcto pero esperaba mas bateria','2025-03-01 10:00:00',TRUE),
 (4,3,5,5,'Gran monitor por el precio','2024-12-01 18:30:00',TRUE),
 (5,4,2,4,'Cumple para trabajar','2025-05-10 09:00:00',TRUE),
 (6,5,9,2,'No me ha convencido','2025-05-15 11:00:00',FALSE),
 (7,2,1,5,'Lo recomiendo','2025-02-20 13:00:00',FALSE);

-- ----------------------------------------------------------------------------
-- Movimientos de puntos (cada euro = 10 puntos). Saldo se calcula desde aqui.
-- ----------------------------------------------------------------------------
INSERT INTO movimiento_puntos (id_cliente, id_pedido, fecha, tipo, puntos) VALUES
 (1,1,'2025-01-16 10:00:00','ganado',13589),
 (1,NULL,'2025-02-20 10:00:00','canjeado',5000),
 (1,NULL,'2025-04-01 10:00:00','canjeado',2000),
 (3,4,'2024-11-22 10:00:00','ganado',4770),
 (4,5,'2025-05-06 10:00:00','ganado',9789),
 (6,8,'2025-04-19 10:00:00','ganado',2679);

-- =============================================================================
-- FIN datos.sql
-- =============================================================================
