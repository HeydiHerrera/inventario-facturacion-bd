# Diccionario de datos

Sistema de Inventario y Facturación (ferretería) · Oracle Database 21c XE (compatible con 12c o superior)

Este documento describe las **15 tablas** del modelo, tal como se crean en [`sql/02_ddl_crear_tablas.sql`](../sql/02_ddl_crear_tablas.sql). Todas las llaves primarias son columnas `NUMBER GENERATED ALWAYS AS IDENTITY` (autogeneradas).

**Convenciones**

- **Llave**: `PK` = llave primaria, `FK` = llave foránea.
- **Longitud**: para `VARCHAR2` es el máximo de caracteres; para `NUMBER` es el número de dígitos o `precisión,escala`; `—` indica que no aplica.
- Las restricciones `CHECK` a nivel de tabla se listan debajo de cada tabla.

## Índice de tablas

| # | Tabla | Grupo | Propósito |
|---|-------|-------|-----------|
| 1 | [`CATEGORIAS`](#categorias) | Catálogos | Clasificación de los productos de la ferretería. |
| 2 | [`PROVEEDORES`](#proveedores) | Catálogos | Empresas que suministran los productos. |
| 3 | [`CLIENTES`](#clientes) | Catálogos | Personas o empresas a quienes se factura. |
| 4 | [`SUCURSALES`](#sucursales) | Catálogos | Puntos de venta de la ferretería. |
| 5 | [`ROLES`](#roles) | Personal y seguridad | Perfiles de acceso al sistema. |
| 6 | [`METODOS_PAGO`](#metodos_pago) | Catálogos | Formas de pago aceptadas. |
| 7 | [`EMPLEADOS`](#empleados) | Personal y seguridad | Personal que trabaja en las sucursales. |
| 8 | [`USUARIOS`](#usuarios) | Personal y seguridad | Cuentas de acceso asociadas a un empleado. |
| 9 | [`PRODUCTOS`](#productos) | Inventario | Artículos a la venta con su existencia. |
| 10 | [`FACTURAS_ENCABEZADO`](#facturas_encabezado) | Ventas | Cabecera de cada venta. |
| 11 | [`FACTURAS_DETALLE`](#facturas_detalle) | Ventas | Líneas de cada factura; tabla puente entre facturas y productos (M:N). |
| 12 | [`PAGOS_FACTURA`](#pagos_factura) | Ventas | Pagos aplicados a las facturas. |
| 13 | [`ORDENES_COMPRA`](#ordenes_compra) | Compras | Cabecera de las compras a proveedores. |
| 14 | [`ORDENES_COMPRA_DETALLE`](#ordenes_compra_detalle) | Compras | Líneas de cada orden de compra; tabla puente entre órdenes y productos (M:N). |
| 15 | [`MOVIMIENTOS_INVENTARIO`](#movimientos_inventario) | Kardex | Kardex: historial de entradas y salidas de cada producto. |

## CATEGORIAS

Clasificación de los productos de la ferretería.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Categoria` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único de la categoría. |
| `Nombre_Categoria` | VARCHAR2 | 50 | — | UNIQUE, NOT NULL | Nombre de la categoría. |
| `Descripcion` | VARCHAR2 | 150 | — | NULL | Detalle de los productos que agrupa. |

## PROVEEDORES

Empresas que suministran los productos.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Proveedor` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del proveedor. |
| `Nombre_Empresa` | VARCHAR2 | 100 | — | NOT NULL | Razón social del proveedor. |
| `NIT` | VARCHAR2 | 15 | — | UNIQUE, NOT NULL | Número de identificación tributaria. |
| `Telefono` | VARCHAR2 | 15 | — | NOT NULL | Teléfono de contacto. |
| `Correo` | VARCHAR2 | 100 | — | UNIQUE, NOT NULL, CHECK (formato de correo) | Correo electrónico. |
| `Contacto_Principal` | VARCHAR2 | 100 | — | NULL | Persona de contacto en la empresa. |

## CLIENTES

Personas o empresas a quienes se factura.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Cliente` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del cliente. |
| `NIT` | VARCHAR2 | 15 | — | UNIQUE, NOT NULL | NIT del cliente; 'CF' identifica al consumidor final. |
| `Nombre_Completo` | VARCHAR2 | 100 | — | NOT NULL | Nombre o razon social. |
| `Direccion` | VARCHAR2 | 200 | — | NULL | Dirección de residencia o fiscal. |
| `Telefono` | VARCHAR2 | 15 | — | NULL | Teléfono de contacto. |
| `Correo` | VARCHAR2 | 100 | — | UNIQUE, NULL, CHECK (formato de correo) | Correo electrónico. |

## SUCURSALES

Puntos de venta de la ferretería.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Sucursal` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único de la sucursal. |
| `Nombre_Sucursal` | VARCHAR2 | 100 | — | UNIQUE, NOT NULL | Nombre de la sucursal. |
| `Direccion` | VARCHAR2 | 200 | — | NOT NULL | Dirección de la sucursal. |
| `Telefono` | VARCHAR2 | 15 | — | NOT NULL | Teléfono de la sucursal. |

## ROLES

Perfiles de acceso al sistema.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Rol` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del rol. |
| `Nombre_Rol` | VARCHAR2 | 50 | — | UNIQUE, NOT NULL | Nombre del rol (Administrador, Cajero, etc.). |
| `Descripcion` | VARCHAR2 | 150 | — | NULL | Alcance del rol. |

## METODOS_PAGO

Formas de pago aceptadas.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Metodo_Pago` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del método de pago. |
| `Nombre_Metodo` | VARCHAR2 | 50 | — | UNIQUE, NOT NULL | Efectivo, tarjeta, transferencia, etc. |

## EMPLEADOS

Personal que trabaja en las sucursales.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Empleado` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del empleado. |
| `DPI_Cedula` | VARCHAR2 | 20 | — | UNIQUE, NOT NULL | Documento personal de identificación. |
| `Nombre_Completo` | VARCHAR2 | 100 | — | NOT NULL | Nombre del empleado. |
| `Cargo` | VARCHAR2 | 50 | — | NOT NULL | Puesto laboral (cajero, bodeguero, etc.). |
| `Salario` | NUMBER | 10,2 | — | NOT NULL, CHECK (> 0) | Salario mensual en quetzales. |
| `Fecha_Contratacion` | DATE | — | — | NOT NULL, DEFAULT SYSDATE | Fecha de ingreso. |
| `ID_Sucursal` | NUMBER | — | FK → `SUCURSALES` | NOT NULL | Sucursal donde labora (SUCURSALES). |

## USUARIOS

Cuentas de acceso asociadas a un empleado.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Usuario` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del usuario. |
| `Username` | VARCHAR2 | 50 | — | UNIQUE, NOT NULL | Nombre de usuario. |
| `Password_Hash` | VARCHAR2 | 128 | — | NOT NULL | Contraseña almacenada como hash SHA-256 (nunca en texto plano). |
| `Estado` | VARCHAR2 | 10 | — | NOT NULL, DEFAULT 'ACTIVO', CHECK (ACTIVO, INACTIVO) | Estado de la cuenta. |
| `ID_Empleado` | NUMBER | — | FK → `EMPLEADOS` | UNIQUE, NOT NULL, ON DELETE CASCADE | Empleado dueño de la cuenta (relación 1:1). |
| `ID_Rol` | NUMBER | — | FK → `ROLES` | NOT NULL | Rol asignado (ROLES). |

## PRODUCTOS

Artículos a la venta con su existencia.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Producto` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del producto. |
| `Codigo_Barras` | VARCHAR2 | 50 | — | UNIQUE, NOT NULL | Código de barras o SKU. |
| `Nombre_Producto` | VARCHAR2 | 100 | — | NOT NULL | Nombre comercial. |
| `Precio_Compra` | NUMBER | 10,2 | — | NOT NULL, CHECK (> 0) | Costo de adquisición por unidad. |
| `Precio_Venta` | NUMBER | 10,2 | — | NOT NULL, CHECK (> 0) | Precio al público por unidad. |
| `Stock_Actual` | NUMBER | 8 | — | NOT NULL, CHECK (>= 0) | Unidades disponibles; lo actualizan los triggers de venta y compra. |
| `Stock_Minimo` | NUMBER | 8 | — | NOT NULL, DEFAULT 5, CHECK (>= 0) | Umbral para considerar el stock bajo. |
| `ID_Categoria` | NUMBER | — | FK → `CATEGORIAS` | NOT NULL | Categoría del producto (CATEGORIAS). |
| `ID_Proveedor` | NUMBER | — | FK → `PROVEEDORES` | NOT NULL | Proveedor habitual (PROVEEDORES). |

**Restricciones a nivel de tabla:**

- `CK_Prod_Margen`: Precio_Venta >= Precio_Compra

## FACTURAS_ENCABEZADO

Cabecera de cada venta.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Factura` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único de la factura. |
| `Numero_Factura` | VARCHAR2 | 20 | — | UNIQUE, NOT NULL | Número correlativo (FACT-AAAA-#####). |
| `Fecha_Emision` | DATE | — | — | NOT NULL, DEFAULT SYSDATE | Fecha de emisión. |
| `Subtotal_Factura` | NUMBER | 12,2 | — | NOT NULL, DEFAULT 0, CHECK (>= 0) | Suma de subtotales del detalle (calculado por trigger). |
| `Impuesto_IVA` | NUMBER | 12,2 | — | NOT NULL, DEFAULT 0, CHECK (>= 0) | IVA 12 % sobre el subtotal (calculado por trigger). |
| `Total_Factura` | NUMBER | 12,2 | — | NOT NULL, DEFAULT 0, CHECK (>= 0) | Subtotal más IVA. |
| `Estado` | VARCHAR2 | 10 | — | NOT NULL, DEFAULT 'PENDIENTE', CHECK (PENDIENTE, PAGADO, ANULADO) | Estado de la factura. |
| `ID_Cliente` | NUMBER | — | FK → `CLIENTES` | NOT NULL | Cliente facturado (CLIENTES). |
| `ID_Empleado` | NUMBER | — | FK → `EMPLEADOS` | NOT NULL | Empleado que realizo la venta (EMPLEADOS). |

**Restricciones a nivel de tabla:**

- `CK_Fac_Total`: Total_Factura = Subtotal_Factura + Impuesto_IVA

## FACTURAS_DETALLE

Líneas de cada factura; tabla puente entre facturas y productos (M:N).

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Detalle` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único de la línea. |
| `ID_Factura` | NUMBER | — | FK → `FACTURAS_ENCABEZADO` | NOT NULL | Factura a la que pertenece (FACTURAS_ENCABEZADO). |
| `ID_Producto` | NUMBER | — | FK → `PRODUCTOS` | NOT NULL | Producto vendido (PRODUCTOS). |
| `Cantidad` | NUMBER | 6 | — | NOT NULL, CHECK (> 0) | Unidades vendidas. |
| `Precio_Unitario` | NUMBER | 10,2 | — | NOT NULL, CHECK (> 0) | Precio vigente al momento de la venta (dato histórico). |
| `Subtotal` | NUMBER | 12,2 | — | VIRTUAL = Cantidad * Precio_Unitario, CHECK (> 0) | Campo calculado por la base de datos. |

## PAGOS_FACTURA

Pagos aplicados a las facturas.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Pago` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del pago. |
| `Monto_Pagado` | NUMBER | 12,2 | — | NOT NULL, CHECK (> 0) | Monto cobrado. |
| `Fecha_Pago` | DATE | — | — | NOT NULL, DEFAULT SYSDATE | Fecha del pago. |
| `Numero_Transaccion` | VARCHAR2 | 50 | — | NULL | Referencia de la transaccion. |
| `ID_Factura` | NUMBER | — | FK → `FACTURAS_ENCABEZADO` | NOT NULL | Factura pagada (FACTURAS_ENCABEZADO). |
| `ID_Metodo_Pago` | NUMBER | — | FK → `METODOS_PAGO` | NOT NULL | Forma de pago (METODOS_PAGO). |

## ORDENES_COMPRA

Cabecera de las compras a proveedores.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Orden_Compra` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único de la orden. |
| `Numero_Orden` | VARCHAR2 | 20 | — | UNIQUE, NOT NULL | Número correlativo (OC-AAAA-####). |
| `Fecha_Orden` | DATE | — | — | NOT NULL, DEFAULT SYSDATE | Fecha de la orden. |
| `Total_Compra` | NUMBER | 12,2 | — | NOT NULL, DEFAULT 0, CHECK (>= 0) | Suma del detalle (calculado por trigger). |
| `Estado_Orden` | VARCHAR2 | 20 | — | NOT NULL, DEFAULT 'PENDIENTE', CHECK (PENDIENTE, RECIBIDA, ANULADA) | Estado de la orden. |
| `ID_Proveedor` | NUMBER | — | FK → `PROVEEDORES` | NOT NULL | Proveedor al que se compra (PROVEEDORES). |
| `ID_Sucursal` | NUMBER | — | FK → `SUCURSALES` | NOT NULL | Sucursal que recibe (SUCURSALES). |

## ORDENES_COMPRA_DETALLE

Líneas de cada orden de compra; tabla puente entre órdenes y productos (M:N).

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Orden_Detalle` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único de la línea. |
| `ID_Orden_Compra` | NUMBER | — | FK → `ORDENES_COMPRA` | NOT NULL | Orden a la que pertenece (ORDENES_COMPRA). |
| `ID_Producto` | NUMBER | — | FK → `PRODUCTOS` | NOT NULL | Producto comprado (PRODUCTOS). |
| `Cantidad` | NUMBER | 6 | — | NOT NULL, CHECK (> 0) | Unidades compradas. |
| `Precio_Compra_Unitario` | NUMBER | 10,2 | — | NOT NULL, CHECK (> 0) | Costo unitario pagado. |
| `Subtotal` | NUMBER | 12,2 | — | VIRTUAL = Cantidad * Precio_Compra_Unitario, CHECK (> 0) | Campo calculado por la base de datos. |

**Restricciones a nivel de tabla:**

- `UQ_OCDet_Orden_Prod`: UNIQUE (ID_Orden_Compra, ID_Producto)

## MOVIMIENTOS_INVENTARIO

Kardex: historial de entradas y salidas de cada producto.

| Campo | Tipo de dato | Longitud | Llave | Restricciones | Descripción |
|-------|--------------|----------|-------|---------------|-------------|
| `ID_Movimiento` | NUMBER | — | PK | IDENTITY (autogenerado) | Identificador único del movimiento. |
| `ID_Producto` | NUMBER | — | FK → `PRODUCTOS` | NOT NULL | Producto afectado (PRODUCTOS). |
| `Fecha_Movimiento` | DATE | — | — | NOT NULL, DEFAULT SYSDATE | Fecha del movimiento. |
| `Tipo_Movimiento` | VARCHAR2 | 10 | — | NOT NULL, CHECK (ENTRADA, SALIDA) | Sentido del movimiento. |
| `Cantidad` | NUMBER | 8 | — | NOT NULL, CHECK (> 0) | Unidades movidas. |
| `Saldo_Resultante` | NUMBER | 8 | — | NOT NULL, CHECK (>= 0) | Stock del producto después del movimiento. |
| `Motivo` | VARCHAR2 | 100 | — | NOT NULL | Descripción (Venta FACT-..., Compra OC-..., Inventario inicial). |
| `ID_Factura` | NUMBER | — | FK → `FACTURAS_ENCABEZADO` | NULL, ON DELETE SET NULL | Factura que origino la salida (opcional). |
| `ID_Orden_Compra` | NUMBER | — | FK → `ORDENES_COMPRA` | NULL, ON DELETE SET NULL | Orden que origino la entrada (opcional). |

**Restricciones a nivel de tabla:**

- `CK_Mov_Origen`: ID_Factura IS NULL OR ID_Orden_Compra IS NULL (un movimiento tiene un solo origen)

## Objetos adicionales de la base de datos

| Objeto | Tipo | Propósito |
|--------|------|-----------|
| `SEQ_NUM_FACTURA` | Secuencia | Numeración correlativa de facturas (`FACT-AAAA-#####`). Inicia en 15 porque los datos de prueba ocupan 1–14. |
| `SEQ_NUM_ORDEN` | Secuencia | Numeración correlativa de órdenes de compra (`OC-AAAA-####`). Inicia en 15. |
| `VW_INVENTARIO_CRITICO` | Vista | Productos con stock igual o menor al mínimo y cantidad sugerida de pedido. |
| `VW_HISTORIAL_CONSOLIDADO` | Vista | Compras por línea y acumulado de ventas por cliente. |
| `sp_registrar_factura` | Procedimiento | Registra una venta completa (factura, detalle, pago) con validación y reversión total ante error. |
| `sp_mover_stock_venta` | Procedimiento | Auxiliar de `trg_actualizar_stock_venta`: aplica el movimiento al stock y lo registra en el kárdex. |
| `sp_registrar_compra` | Procedimiento | Registra una compra a proveedor y aumenta el stock y el kárdex. |
| `trg_validar_stock_venta` | Trigger | **Verificación de la venta**: stock suficiente, factura abierta, producto existente y precio no menor al costo. |
| `trg_actualizar_stock_venta` | Trigger | **Actualización del stock**: descuenta o repone el inventario y escribe el kárdex por cada línea de venta. |
| `trg_anular_factura` | Trigger | Devuelve el stock al anular una factura y evita reactivarla. |
| `trg_calc_total_factura` | Trigger | Recalcula subtotal, IVA y total de la factura desde su detalle. |
| `trg_calc_total_compra` | Trigger | Recalcula el total de la orden de compra desde su detalle. |
| `t_linea_factura`, `t_lineas_factura`, `t_linea_compra`, `t_lineas_compra` | Tipos | Colecciones usadas como parámetros de los procedimientos. |
