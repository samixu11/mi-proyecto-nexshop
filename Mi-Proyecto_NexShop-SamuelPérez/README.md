# Proyecto Base de Datos — NexShop Group S.A.

**Autor:** Erik Mora

Diseño e implementación desde cero de la base de datos corporativa de **NexShop Group S.A.**,
empresa de distribución y retail fundada en 2015 (sede en Valencia) que vende a través de su tienda
online *nexshop.es* y de tres tiendas físicas (Valencia, Madrid y Barcelona) apoyadas por un almacén
central. La base de datos cubre catálogo, ventas online y presenciales, aprovisionamiento, inventario
entre sedes, atención al cliente, valoraciones y el programa de puntos de fidelización.

El modelo consta de **25 tablas base + 1 vista** y está validado en **MySQL 8 / MariaDB 10.11**.

---

## Estructura del repositorio

```
mi-proyecto-nexshop/
├── README.md
├── docs/
│   ├── memoria.pdf              # Análisis y justificación + 6 preguntas de reflexión
│   ├── diagrama_er.png          # Diagrama entidad-relación (notación pata de gallo)
│   ├── modelo_relacional.pdf    # Modelo relacional (PK/FK, resolución de N:M)
│   └── project_board.md         # Guía para montar el tablero de proyecto en GitHub
├── sql/
│   ├── schema.sql               # Creación de la BD y las 25 tablas + vista
│   └── datos.sql                # Datos de prueba realistas
└── consultas/
    └── consultas.sql            # 14 consultas obligatorias + 5 adicionales
```

---

## Requisitos

- MySQL 8.x o MariaDB 10.4+
- Cliente de línea de comandos `mysql` (o cualquier GUI: MySQL Workbench, DBeaver, phpMyAdmin…)

## Cómo importar y probar

Desde la carpeta raíz del proyecto, ejecutar en orden:

```bash
# 1) Crear la base de datos y todas las tablas (+ la vista)
mysql -u root -p < sql/schema.sql

# 2) Cargar los datos de prueba
mysql -u root -p nexshop < sql/datos.sql

# 3) Ejecutar la batería de consultas
mysql -u root -p nexshop < consultas/consultas.sql
```

> `schema.sql` ya incluye `CREATE DATABASE nexshop` y `USE nexshop`, por lo que no hace falta crearla
> a mano. Los pasos 2 y 3 indican la base de datos `nexshop` por si tu cliente no la selecciona sola.

Comprobación rápida (deberían salir 25 tablas):

```sql
USE nexshop;
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'nexshop' AND table_type = 'BASE TABLE';
```

---

## Diagrama entidad-relación

![Diagrama ER de NexShop](docs/diagrama_er.png)

El diagrama completo, junto con la justificación de cada decisión de diseño y las respuestas a las
6 preguntas de reflexión, está en [`docs/memoria.pdf`](docs/memoria.pdf). El modelo relacional con
todas las claves primarias y ajenas está en [`docs/modelo_relacional.pdf`](docs/modelo_relacional.pdf).

---

## Resumen del modelo

- **Catálogo:** `categoria` → `subcategoria` → `producto`, con `historico_precio` para la auditoría de PVP.
- **Promociones:** `promocion` y la puente `promocion_producto` (N:M); separadas del precio base.
- **Aprovisionamiento:** `suministro` resuelve el N:M producto–proveedor con precio de coste, plazo e
  historial de condiciones (vigente = `fecha_fin IS NULL`).
- **Canal online:** `pedido` → `linea_pedido`; un pedido genera varios `envio` (1:N) y cada envío
  detalla su contenido en `linea_envio` (envíos parciales desde distintos almacenes).
- **Canal físico:** `ticket_venta` → `linea_ticket_venta` (cliente opcional para ventas anónimas);
  `devolucion` → `linea_devolucion`.
- **Atención al cliente:** `incidencia` (las devoluciones online se gestionan aquí).
- **Inventario:** `stock` por ubicación y `transferencia` entre sedes.
- **Fidelización:** `movimiento_puntos` como única fuente del saldo; la vista `v_saldo_puntos` lo calcula.

---

## Tablero de proyecto

La planificación por fases (modelo, SQL, consultas, documentación) se organiza en un tablero de
GitHub Projects. Las instrucciones para crearlo y las tarjetas sugeridas están en
[`docs/project_board.md`](docs/project_board.md).
