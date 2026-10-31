# Descripción del sistema

## 1. Contexto del negocio

El sistema da soporte a una **ferretería con cinco sucursales** (Sede Central, Zona 10, Mixco, Villa Nueva y Antigua Guatemala). Controla el inventario, administra el catálogo de productos, proveedores y clientes, y cubre el proceso completo de venta con su factura.

**¿Qué se vende?** Productos de ocho categorías: herramientas manuales, material eléctrico, plomería, pinturas y acabados, fijaciones y tornillería, seguridad industrial, jardinería y construcción.

**¿Cómo se factura?**

1. El vendedor o cajero registra una factura a nombre de un cliente (o del consumidor final, NIT `CF`).
2. Cada línea de la factura indica el producto, la cantidad y el precio vigente.
3. El sistema calcula el subtotal de cada línea, el subtotal de la factura, el **IVA del 12 %** y el total.
4. La factura se paga con uno de los métodos de pago (efectivo, tarjeta POS, transferencia, cheque o depósito) y pasa a `PAGADO`; si no se paga queda `PENDIENTE`; si se cancela queda `ANULADO`.

**¿Cómo se controla el stock?**

- Cada producto tiene `Stock_Actual` y un `Stock_Minimo`. Cuando el stock baja del mínimo, el producto aparece en el reporte de bajo stock y en la vista `VW_INVENTARIO_CRITICO`.
- Cada venta **descuenta** el stock y cada compra a proveedor lo **aumenta**; ambos movimientos quedan registrados en el kárdex (`MOVIMIENTOS_INVENTARIO`) con el saldo resultante.
- Anular una factura **devuelve** las unidades al inventario.

## 2. Módulos del sistema

| Módulo | Tablas principales | Descripción |
|--------|--------------------|-------------|
| Catálogo | `CATEGORIAS`, `PROVEEDORES`, `CLIENTES`, `SUCURSALES`, `METODOS_PAGO` | Datos maestros sobre los que se apoya todo el sistema. |
| Control de existencias | `PRODUCTOS`, `MOVIMIENTOS_INVENTARIO` | Productos con precio de compra, precio de venta, stock actual y mínimo, y su kárdex. |
| Facturación | `FACTURAS_ENCABEZADO`, `FACTURAS_DETALLE`, `PAGOS_FACTURA` | Facturas con encabezado, detalle línea por línea y pagos. |
| Compras | `ORDENES_COMPRA`, `ORDENES_COMPRA_DETALLE` | Entradas de inventario por proveedor. |
| Personal y seguridad | `EMPLEADOS`, `USUARIOS`, `ROLES` | Quién vende y con qué permisos accede al sistema. |
| Reportes | consultas Q1–Q15 y vistas | Bajo stock, ventas por cliente, producto y fecha, compras por proveedor, entre otros. |

## 3. Reglas de negocio

Las reglas se aplican en la base de datos (no dependen de la aplicación), de modo que no pueden saltarse.

| Código | Regla | Dónde se aplica |
|--------|-------|------------------|
| RN-01 | El NIT del cliente es único. | `UNIQUE` en `CLIENTES.NIT` |
| RN-02 | El código de barras del producto es único. | `UNIQUE` en `PRODUCTOS.Codigo_Barras` |
| RN-03 | Los precios deben ser mayores a cero y el precio de venta no puede ser menor al de compra. | `CHECK` en `PRODUCTOS` |
| RN-04 | El stock nunca puede ser negativo. | `CHECK (Stock_Actual >= 0)` |
| RN-05 | **No se puede vender más unidades que el stock disponible.** | `trg_validar_stock_venta` y `sp_registrar_factura` |
| RN-06 | Solo se pueden agregar, modificar o quitar líneas de una factura `PENDIENTE`. | `trg_validar_stock_venta` |
| RN-07 | No se puede vender por debajo del precio de compra. | `trg_validar_stock_venta` |
| RN-08 | **Cada línea de venta descuenta el stock y registra una salida en el kárdex.** | `trg_actualizar_stock_venta` |
| RN-09 | Modificar la cantidad de una línea ajusta el stock; eliminarla lo repone. | `trg_actualizar_stock_venta` |
| RN-10 | Anular una factura devuelve el stock; una factura anulada no puede reactivarse. | `trg_anular_factura` |
| RN-11 | Subtotal, IVA (12 %) y total de la factura se calculan a partir del detalle. | `trg_calc_total_factura`, `CK_Fac_Total` |
| RN-12 | Una compra recibida aumenta el stock y registra una entrada en el kárdex. | `sp_registrar_compra` |
| RN-13 | El total de la orden de compra se calcula a partir de su detalle. | `trg_calc_total_compra` |
| RN-14 | Un producto aparece una sola vez por orden de compra. | `UNIQUE (ID_Orden_Compra, ID_Producto)` |
| RN-15 | Un empleado tiene como máximo una cuenta de usuario. | `UNIQUE` en `USUARIOS.ID_Empleado` |
| RN-16 | Las contraseñas se guardan como hash SHA-256, nunca en texto plano. | `STANDARD_HASH` en la carga de usuarios |

## 4. Lógica automática (verificación de venta y actualización de stock)

Al registrar una venta intervienen tres elementos que trabajan en este orden:

```
 sp_registrar_factura            (valida cliente, empleado, producto, cantidad y stock)
        │  INSERT de cada línea
        ▼
 trg_validar_stock_venta         BEFORE  → verifica la venta; si falla, rechaza la línea
        │  (línea aceptada)
        ▼
 trg_actualizar_stock_venta      AFTER   → llama a sp_mover_stock_venta: descuenta Stock_Actual y escribe el kárdex (SALIDA)
        │
        ▼
 trg_calc_total_factura          AFTER   → recalcula subtotal, IVA y total de la factura
```

Como la validación y la actualización viven en **triggers sobre `FACTURAS_DETALLE`**, funcionan igual si la venta se registra con el procedimiento o con un `INSERT` directo: no hay forma de vender sin que se verifique el stock ni de descontar el stock dos veces.

| Operación sobre una línea de factura | Efecto en `PRODUCTOS.Stock_Actual` | Registro en el kárdex |
|--------------------------------------|-------------------------------------|------------------------|
| `INSERT` (venta) | disminuye en `Cantidad` | `SALIDA` |
| `UPDATE` aumentando `Cantidad` | disminuye en la diferencia | `SALIDA` por la diferencia |
| `UPDATE` reduciendo `Cantidad` | aumenta en la diferencia | `ENTRADA` por la diferencia |
| `DELETE` de la línea | aumenta en `Cantidad` | `ENTRADA` |
| Factura pasa a `ANULADO` | aumenta en la cantidad de cada línea | `ENTRADA` por línea |

> **Nota sobre el orden de ejecución.** Los datos de prueba (`03_dml_datos_prueba.sql`) cargan el kárdex y las existencias finales de forma explícita, por lo que se ejecutan **antes** de crear los triggers (`05_extras_opcional.sql`). Si los triggers ya existieran, descontarían el stock por segunda vez.

## 5. Alcance y tecnología

- **Motor:** Oracle Database 21c Express Edition (XEPDB1); requiere 12c o superior por las columnas `IDENTITY`, las columnas virtuales y `FETCH FIRST`.
- **Evolución del modelo:** la Fase 1 presentó 14 tablas; en la Fase 2 se agregó `MOVIMIENTOS_INVENTARIO` (kárdex) para auditar el stock, con lo que el modelo final tiene 15.
- **Modelo:** 15 tablas normalizadas hasta la 3FN (ver [diccionario de datos](02_diccionario_datos.md), [justificación de relaciones](03_justificacion_relaciones.md) y [normalización](04_normalizacion.md)).
- **Fuera de alcance:** interfaz gráfica, cobro con pasarelas de pago reales, facturación electrónica (FEL) y devoluciones parciales de mercadería.

## 6. Datos de prueba

| Elemento | Cantidad | Mínimo de la guía |
|----------|----------|-------------------|
| Categorías | 8 | 5 |
| Proveedores | 15 | 5 |
| Clientes | 16 | 10 |
| Productos | 32 (8 con stock bajo, 6 nunca vendidos) | 30 |
| Facturas | 14 (13 con pago, 1 pendiente) | 10 |
| Líneas de detalle de factura | 32 | 30 |
| Órdenes de compra | 14 (12 recibidas, 1 pendiente, 1 anulada) | — |
