-- =============================================================================
--  NexShop Group S.A.  |  schema.sql
--  Esquema relacional completo (MySQL 8.x / InnoDB / utf8mb4)
--  Autor: Samuel Pérez-Herrero Soler
-- -----------------------------------------------------------------------------
--  Convenciones:
--    * Claves primarias surrogadas INT AUTO_INCREMENT salvo tablas puente.
--    * Toda relacion N:M se resuelve con tabla puente (ver comentarios).
--    * Los historicos (precios, suministros, puntos) se modelan como filas
--      con vigencia temporal; el "valor actual" es la fila con fecha_fin NULL.
--    * Importes en DECIMAL(10,2); porcentajes en DECIMAL(5,2).
-- =============================================================================

DROP DATABASE IF EXISTS nexshop;
CREATE DATABASE nexshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nexshop;

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- 1. CATALOGO: categoria / subcategoria / producto
-- =============================================================================

-- [Lo pide el cliente] Categorias del catalogo (ej. "Informatica").
CREATE TABLE categoria (
    id_categoria   INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(80)  NOT NULL UNIQUE
) ENGINE=InnoDB;

-- [Lo pide el cliente] Subcategorias dependientes de una categoria (ej. "Portatiles").
-- Un producto pertenece a UNA subcategoria => la jerarquia se modela aqui.
CREATE TABLE subcategoria (
    id_subcategoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(80) NOT NULL,
    id_categoria    INT NOT NULL,
    CONSTRAINT fk_subcat_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    CONSTRAINT uq_subcat UNIQUE (id_categoria, nombre)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Producto. "Un producto NUNCA pertenece a dos subcategorias"
-- => id_subcategoria es un unico FK NOT NULL (relacion 1:N subcategoria-producto).
-- pvp = precio de venta vigente (conveniencia para consultas); el historico
-- completo vive en historico_precio (ver pregunta de reflexion 3).
CREATE TABLE producto (
    id_producto     INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    descripcion     TEXT,
    pvp             DECIMAL(10,2) NOT NULL,
    id_subcategoria INT NOT NULL,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_producto_subcat
        FOREIGN KEY (id_subcategoria) REFERENCES subcategoria(id_subcategoria),
    CONSTRAINT chk_pvp CHECK (pvp >= 0)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Historico de PVP. Cada cambio de precio base genera una fila.
-- La fila con fecha_fin NULL es el precio vigente. Distinto de una promocion.
CREATE TABLE historico_precio (
    id_historico_precio INT AUTO_INCREMENT PRIMARY KEY,
    id_producto         INT NOT NULL,
    precio              DECIMAL(10,2) NOT NULL,
    fecha_inicio        DATE NOT NULL,
    fecha_fin           DATE NULL,
    CONSTRAINT fk_histprecio_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT chk_histprecio_valor CHECK (precio >= 0),
    CONSTRAINT chk_histprecio_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- =============================================================================
-- 2. PROMOCIONES (marketing)
-- =============================================================================

-- [Lo pide el cliente] Promocion: descuento % sobre el PVP en un rango de fechas.
CREATE TABLE promocion (
    id_promocion   INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(120) NOT NULL,
    descuento_pct  DECIMAL(5,2) NOT NULL,
    fecha_inicio   DATE NOT NULL,
    fecha_fin      DATE NOT NULL,
    CONSTRAINT chk_promo_pct   CHECK (descuento_pct > 0 AND descuento_pct <= 100),
    CONSTRAINT chk_promo_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- [Lo propongo yo] Tabla puente promocion <-> producto (N:M).
-- Una promocion afecta a varios productos y un producto puede tener varias
-- promociones a lo largo del tiempo => resolucion N:M con clave compuesta.
CREATE TABLE promocion_producto (
    id_promocion INT NOT NULL,
    id_producto  INT NOT NULL,
    PRIMARY KEY (id_promocion, id_producto),
    CONSTRAINT fk_promoprod_promo
        FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion),
    CONSTRAINT fk_promoprod_prod
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
) ENGINE=InnoDB;

-- =============================================================================
-- 3. SEDES, EMPLEADOS Y PROVEEDORES
-- =============================================================================

-- [Lo pide el cliente] Ubicacion fisica con stock propio: tiendas y almacen central.
-- El "encargado" de una tienda es el empleado con puesto='encargado' asignado a
-- esa ubicacion (se evita FK circular ubicacion<->empleado).
CREATE TABLE ubicacion (
    id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    tipo         ENUM('tienda','almacen') NOT NULL,
    ciudad       VARCHAR(80) NOT NULL,
    direccion    VARCHAR(200)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Empleado. Asignado a una sede. El puesto permite identificar
-- vendedor / encargado / agente de atencion al cliente / comercial / etc.
CREATE TABLE empleado (
    id_empleado        INT AUTO_INCREMENT PRIMARY KEY,
    nombre             VARCHAR(80)  NOT NULL,
    apellidos          VARCHAR(120) NOT NULL,
    dni                VARCHAR(15)  NOT NULL UNIQUE,
    email_corporativo  VARCHAR(150) NOT NULL UNIQUE,
    fecha_incorporacion DATE NOT NULL,
    puesto             ENUM('encargado','vendedor','responsable_almacen',
                            'logistica','compras','atencion_cliente',
                            'comercial','direccion','it') NOT NULL,
    id_ubicacion       INT NOT NULL,
    CONSTRAINT fk_empleado_ubicacion
        FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Proveedor con su representante comercial de NexShop (empleado).
CREATE TABLE proveedor (
    id_proveedor   INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(150) NOT NULL,
    cif            VARCHAR(15) UNIQUE,
    email          VARCHAR(150),
    telefono       VARCHAR(20),
    id_representante INT NULL,   -- empleado de NexShop que gestiona la relacion
    CONSTRAINT fk_proveedor_repr
        FOREIGN KEY (id_representante) REFERENCES empleado(id_empleado)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Suministro: resuelve el N:M producto<->proveedor CON historico.
-- Para cada combinacion se pacta precio_coste y plazo_entrega; al cambiar las
-- condiciones se cierra la fila (fecha_fin) y se abre otra. Vigente = fecha_fin NULL.
CREATE TABLE suministro (
    id_suministro    INT AUTO_INCREMENT PRIMARY KEY,
    id_producto      INT NOT NULL,
    id_proveedor     INT NOT NULL,
    precio_coste     DECIMAL(10,2) NOT NULL,
    plazo_entrega_dias INT NOT NULL,
    fecha_inicio     DATE NOT NULL,
    fecha_fin        DATE NULL,
    CONSTRAINT fk_suministro_prod
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT fk_suministro_prov
        FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor),
    CONSTRAINT chk_suministro_coste CHECK (precio_coste >= 0),
    CONSTRAINT chk_suministro_plazo CHECK (plazo_entrega_dias >= 0),
    CONSTRAINT chk_suministro_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- =============================================================================
-- 4. CLIENTES, DIRECCIONES
-- =============================================================================

-- [Lo pide el cliente] Cliente registrado online. email/password NULL permiten
-- representar tambien a un cliente creado al vincular compras presenciales.
-- telefono se incluye para soportar la consulta de actualizacion (Fase 5, #13).
CREATE TABLE cliente (
    id_cliente       INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(80)  NOT NULL,
    apellidos        VARCHAR(120) NOT NULL,
    email            VARCHAR(150) UNIQUE,           -- NULL si aun no se ha registrado online
    password_hash    VARCHAR(255),
    telefono         VARCHAR(20),
    fecha_nacimiento DATE,                          -- usado para la promo de cumpleanos
    fecha_registro   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- [Lo pide el cliente] Direcciones del cliente (domicilio/trabajo/otra). 1:N.
CREATE TABLE direccion (
    id_direccion  INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT NOT NULL,
    tipo          ENUM('domicilio','trabajo','otra') NOT NULL DEFAULT 'domicilio',
    calle         VARCHAR(150) NOT NULL,
    numero        VARCHAR(10),
    piso          VARCHAR(10),
    codigo_postal VARCHAR(10) NOT NULL,
    ciudad        VARCHAR(80) NOT NULL,
    pais          VARCHAR(60) NOT NULL DEFAULT 'Espana',
    CONSTRAINT fk_direccion_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
) ENGINE=InnoDB;

-- =============================================================================
-- 5. CANAL ONLINE: pedido / linea_pedido / envio / linea_envio
-- =============================================================================

-- [Lo pide el cliente] Pedido online. Requiere cliente registrado y direccion de envio.
CREATE TABLE pedido (
    id_pedido       INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente      INT NOT NULL,
    id_direccion    INT NOT NULL,
    fecha_pedido    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          ENUM('pendiente','pagado','enviado','entregado','cancelado')
                        NOT NULL DEFAULT 'pendiente',
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_pedido_direccion
        FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Lineas del pedido. precio_unitario congela el PVP del momento.
CREATE TABLE linea_pedido (
    id_pedido        INT NOT NULL,
    id_producto      INT NOT NULL,
    cantidad         INT NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    descuento_pct    DECIMAL(5,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_pedido, id_producto),
    CONSTRAINT fk_lp_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_lp_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT chk_lp_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_lp_precio   CHECK (precio_unitario >= 0),
    CONSTRAINT chk_lp_desc     CHECK (descuento_pct >= 0 AND descuento_pct <= 100)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Envio. Un pedido puede generar VARIOS envios (1:N), cada uno
-- desde una ubicacion origen distinta. tipo distingue entrega vs recogida (devolucion online).
CREATE TABLE envio (
    id_envio           INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido          INT NOT NULL,
    id_ubicacion_origen INT NOT NULL,
    tipo               ENUM('entrega','recogida') NOT NULL DEFAULT 'entrega',
    numero_seguimiento VARCHAR(50) UNIQUE,
    transportista      VARCHAR(80),
    fecha_estimada     DATE,
    fecha_envio        DATE NULL,
    estado             ENUM('preparando','en_transito','entregado','incidencia')
                            NOT NULL DEFAULT 'preparando',
    CONSTRAINT fk_envio_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_envio_origen
        FOREIGN KEY (id_ubicacion_origen) REFERENCES ubicacion(id_ubicacion)
) ENGINE=InnoDB;

-- [Lo propongo yo] Lineas del envio: que productos/cantidades van en cada envio parcial.
-- Necesario porque un pedido se puede repartir en varios envios desde almacenes distintos.
CREATE TABLE linea_envio (
    id_envio    INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad    INT NOT NULL,
    PRIMARY KEY (id_envio, id_producto),
    CONSTRAINT fk_le_envio
        FOREIGN KEY (id_envio) REFERENCES envio(id_envio) ON DELETE CASCADE,
    CONSTRAINT fk_le_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT chk_le_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- =============================================================================
-- 6. CANAL FISICO: ticket_venta / linea_ticket_venta / devolucion / linea_devolucion
-- =============================================================================

-- [Lo pide el cliente] Venta presencial en tienda. id_cliente es NULL en ventas
-- anonimas; se rellena al vincular el historial a una cuenta (pregunta de reflexion 5).
CREATE TABLE ticket_venta (
    id_ticket_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_ubicacion    INT NOT NULL,           -- tienda donde se realiza
    id_empleado     INT NOT NULL,           -- vendedor que la realiza
    id_cliente      INT NULL,               -- NULL = venta anonima
    fecha_hora      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tv_ubicacion
        FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion),
    CONSTRAINT fk_tv_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
    CONSTRAINT fk_tv_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Lineas del ticket de venta presencial.
CREATE TABLE linea_ticket_venta (
    id_ticket_venta INT NOT NULL,
    id_producto     INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_ticket_venta, id_producto),
    CONSTRAINT fk_ltv_ticket
        FOREIGN KEY (id_ticket_venta) REFERENCES ticket_venta(id_ticket_venta) ON DELETE CASCADE,
    CONSTRAINT fk_ltv_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT chk_ltv_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_ltv_precio   CHECK (precio_unitario >= 0)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Devolucion presencial, vinculada al ticket original.
CREATE TABLE devolucion (
    id_devolucion   INT AUTO_INCREMENT PRIMARY KEY,
    id_ticket_venta INT NOT NULL,
    id_empleado     INT NOT NULL,
    fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo          VARCHAR(200),
    CONSTRAINT fk_dev_ticket
        FOREIGN KEY (id_ticket_venta) REFERENCES ticket_venta(id_ticket_venta),
    CONSTRAINT fk_dev_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
) ENGINE=InnoDB;

-- [Lo propongo yo] Lineas de la devolucion (productos/cantidades devueltos).
CREATE TABLE linea_devolucion (
    id_devolucion INT NOT NULL,
    id_producto   INT NOT NULL,
    cantidad      INT NOT NULL,
    PRIMARY KEY (id_devolucion, id_producto),
    CONSTRAINT fk_ld_devolucion
        FOREIGN KEY (id_devolucion) REFERENCES devolucion(id_devolucion) ON DELETE CASCADE,
    CONSTRAINT fk_ld_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT chk_ld_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- =============================================================================
-- 7. ATENCION AL CLIENTE: incidencia (tickets)
-- =============================================================================

-- [Lo pide el cliente] Ticket de incidencia. Puede o no estar ligado a un pedido.
-- Las devoluciones online se gestionan como incidencia (tipo='devolucion_online').
CREATE TABLE incidencia (
    id_incidencia    INT AUTO_INCREMENT PRIMARY KEY,
    asunto           VARCHAR(150) NOT NULL,
    descripcion      TEXT,
    fecha_apertura   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado           ENUM('abierto','en_gestion','resuelto') NOT NULL DEFAULT 'abierto',
    tipo             ENUM('consulta','queja','devolucion_online') NOT NULL DEFAULT 'consulta',
    id_empleado      INT NOT NULL,          -- agente que la gestiona
    id_cliente       INT NULL,
    id_pedido        INT NULL,              -- opcional: incidencia sobre un pedido
    fecha_cierre     DATETIME NULL,
    nota_resolucion  TEXT NULL,
    CONSTRAINT fk_inc_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
    CONSTRAINT fk_inc_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_inc_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    CONSTRAINT chk_inc_cierre
        CHECK ( (estado = 'resuelto' AND fecha_cierre IS NOT NULL)
             OR (estado <> 'resuelto') )
) ENGINE=InnoDB;

-- =============================================================================
-- 8. STOCK Y TRANSFERENCIAS INTERNAS
-- =============================================================================

-- [Lo pide el cliente] Stock por ubicacion y producto (clave compuesta).
CREATE TABLE stock (
    id_ubicacion INT NOT NULL,
    id_producto  INT NOT NULL,
    cantidad     INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_ubicacion, id_producto),
    CONSTRAINT fk_stock_ubicacion
        FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion),
    CONSTRAINT fk_stock_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT chk_stock_cantidad CHECK (cantidad >= 0)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Transferencia interna de stock entre ubicaciones.
CREATE TABLE transferencia (
    id_transferencia    INT AUTO_INCREMENT PRIMARY KEY,
    fecha               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_ubicacion_origen INT NOT NULL,
    id_ubicacion_destino INT NOT NULL,
    id_producto         INT NOT NULL,
    cantidad            INT NOT NULL,
    id_empleado         INT NOT NULL,       -- empleado que la autoriza
    CONSTRAINT fk_transf_origen
        FOREIGN KEY (id_ubicacion_origen) REFERENCES ubicacion(id_ubicacion),
    CONSTRAINT fk_transf_destino
        FOREIGN KEY (id_ubicacion_destino) REFERENCES ubicacion(id_ubicacion),
    CONSTRAINT fk_transf_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT fk_transf_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
    CONSTRAINT chk_transf_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_transf_distinta CHECK (id_ubicacion_origen <> id_ubicacion_destino)
) ENGINE=InnoDB;

-- =============================================================================
-- 9. VALORACIONES Y FIDELIZACION
-- =============================================================================

-- [Lo pide el cliente] Valoracion de producto por cliente. UNA por cliente-producto.
-- verificada = TRUE si proviene de compra confirmada.
CREATE TABLE valoracion (
    id_valoracion INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT NOT NULL,
    id_producto   INT NOT NULL,
    puntuacion    TINYINT NOT NULL,
    comentario    TEXT,
    fecha         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verificada    BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_val_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_val_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT uq_val_cliente_producto UNIQUE (id_cliente, id_producto),
    CONSTRAINT chk_val_punt CHECK (puntuacion BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- [Lo pide el cliente] Movimientos de puntos de fidelizacion. El saldo SIEMPRE se
-- calcula sumando este historico (no se guarda saldo_actual; ver reflexion 4).
CREATE TABLE movimiento_puntos (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT NOT NULL,
    id_pedido     INT NULL,               -- pedido que origino el movimiento (si aplica)
    fecha         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo          ENUM('ganado','canjeado') NOT NULL,
    puntos        INT NOT NULL,           -- siempre positivo; el signo lo da 'tipo'
    CONSTRAINT fk_mp_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_mp_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    CONSTRAINT chk_mp_puntos CHECK (puntos > 0)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 10. VISTA: saldo de puntos calculado desde el historico
-- =============================================================================

-- [Lo propongo yo] Vista que materializa el saldo de puntos por cliente a partir
-- del historico de movimientos (unica fuente de verdad).
CREATE OR REPLACE VIEW v_saldo_puntos AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellidos,
    COALESCE(SUM(CASE WHEN mp.tipo = 'ganado'  THEN mp.puntos
                      WHEN mp.tipo = 'canjeado' THEN -mp.puntos END), 0) AS saldo_puntos
FROM cliente c
LEFT JOIN movimiento_puntos mp ON mp.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellidos;

-- =============================================================================
-- FIN schema.sql
-- =============================================================================
