# Normalización hasta la 3FN

Este documento demuestra que el modelo cumple la primera, segunda y tercera forma normal. Primero se muestra el proceso con un ejemplo completo (una factura en papel) y después se aplica el análisis a cada una de las 15 tablas.

> La Fase 1 documentó la normalización de 14 entidades. Este documento la amplía a las 15 tablas del modelo final, que incorpora el kárdex agregado en la Fase 2.

## 1. Proceso de normalización con un ejemplo

### Punto de partida: la factura sin normalizar (UNF)

Una factura en papel mezcla en un solo registro datos del cliente, del vendedor, de los productos y de la venta:

| Numero_Factura | Fecha | NIT_Cliente | Nombre_Cliente | Direccion_Cliente | Productos vendidos (lista) | Total |
|----------------|-------|-------------|----------------|-------------------|----------------------------|-------|
| FACT-2026-00001 | 2026-09-05 | 1123456-7 | Juan Perez | Zona 1, Ciudad de Guatemala | Martillo (2 × Q45.00); Desarmador (3 × Q18.00) | 161.28 |

Problemas: la columna de productos contiene varios valores y los datos del cliente se repetirían en cada factura del mismo cliente.

### Primera forma normal (1FN)

**Regla:** todos los valores son atómicos, no hay grupos repetidos y cada tabla tiene llave primaria.

Se separa cada producto en su propia fila:

| Numero_Factura | Fecha | NIT_Cliente | Nombre_Cliente | Direccion_Cliente | Codigo_Barras | Nombre_Producto | Cantidad | Precio |
|----------------|-------|-------------|----------------|-------------------|---------------|-----------------|----------|--------|
| FACT-2026-00001 | 2026-09-05 | 1123456-7 | Juan Perez | Zona 1 | BARR-001 | Martillo de Acero 16oz | 2 | 45.00 |
| FACT-2026-00001 | 2026-09-05 | 1123456-7 | Juan Perez | Zona 1 | BARR-003 | Desarmador Phillips #2 | 3 | 18.00 |

Llave primaria compuesta: (`Numero_Factura`, `Codigo_Barras`).

### Segunda forma normal (2FN)

**Regla:** 1FN y ningún atributo depende solo de una parte de la llave compuesta.

Dependencias parciales encontradas:

- `Numero_Factura` → `Fecha`, `NIT_Cliente`, `Nombre_Cliente`, `Direccion_Cliente` (dependen solo de la factura).
- `Codigo_Barras` → `Nombre_Producto` (depende solo del producto).

Solo `Cantidad` y el precio cobrado dependen de la llave completa. Se separa en tres tablas: `FACTURAS_ENCABEZADO`, `PRODUCTOS` y `FACTURAS_DETALLE`.

### Tercera forma normal (3FN)

**Regla:** 2FN y ningún atributo no clave depende de otro atributo no clave (no hay dependencias transitivas).

Dependencias transitivas encontradas en el encabezado y en los productos:

- `Numero_Factura` → `NIT_Cliente` → `Nombre_Cliente`, `Direccion_Cliente`. El nombre y la dirección dependen del cliente, no de la factura → se crea `CLIENTES`.
- `ID_Producto` → `ID_Categoria` → `Nombre_Categoria`. El nombre de la categoría depende de la categoría, no del producto → se crea `CATEGORIAS`.
- `ID_Producto` → `ID_Proveedor` → `Nombre_Empresa`, `NIT`, `Telefono` → se crea `PROVEEDORES`.

El resultado de este proceso, ampliado con compras, pagos, personal y kárdex, es el modelo de 15 tablas.

## 2. Análisis por tabla

Cada tabla tiene una **llave primaria simple y subrogada** (`IDENTITY`). Por eso la 2FN se cumple de forma trivial: ninguna dependencia puede ser parcial respecto a una llave de una sola columna. Además se analizaron las llaves candidatas naturales (columnas `UNIQUE`) y la 3FN (ausencia de dependencias entre atributos no clave).

| Tabla | Dependencias funcionales principales | 1FN | 2FN | 3FN |
|-------|--------------------------------------|:---:|:---:|:---:|
| `CATEGORIAS` | `ID_Categoria` → `Nombre_Categoria`, `Descripcion`; `Nombre_Categoria` → `ID_Categoria` | ✔ | ✔ | ✔ |
| `PROVEEDORES` | `ID_Proveedor` → `Nombre_Empresa`, `NIT`, `Telefono`, `Correo`, `Contacto_Principal`; `NIT` → `ID_Proveedor`; `Correo` → `ID_Proveedor` | ✔ | ✔ | ✔ |
| `CLIENTES` | `ID_Cliente` → `NIT`, `Nombre_Completo`, `Direccion`, `Telefono`, `Correo`; `NIT` → `ID_Cliente`; `Correo` → `ID_Cliente` | ✔ | ✔ | ✔ |
| `SUCURSALES` | `ID_Sucursal` → `Nombre_Sucursal`, `Direccion`, `Telefono`; `Nombre_Sucursal` → `ID_Sucursal` | ✔ | ✔ | ✔ |
| `ROLES` | `ID_Rol` → `Nombre_Rol`, `Descripcion`; `Nombre_Rol` → `ID_Rol` | ✔ | ✔ | ✔ |
| `METODOS_PAGO` | `ID_Metodo_Pago` → `Nombre_Metodo`; `Nombre_Metodo` → `ID_Metodo_Pago` | ✔ | ✔ | ✔ |
| `EMPLEADOS` | `ID_Empleado` → `DPI_Cedula`, `Nombre_Completo`, `Cargo`, `Salario`, `Fecha_Contratacion`, `ID_Sucursal`; `DPI_Cedula` → `ID_Empleado` | ✔ | ✔ | ✔ |
| `USUARIOS` | `ID_Usuario` → `Username`, `Password_Hash`, `Estado`, `ID_Empleado`, `ID_Rol`; `Username` → `ID_Usuario`; `ID_Empleado` → `ID_Usuario` | ✔ | ✔ | ✔ |
| `PRODUCTOS` | `ID_Producto` → `Codigo_Barras`, `Nombre_Producto`, `Precio_Compra`, `Precio_Venta`, `Stock_Actual`, `Stock_Minimo`, `ID_Categoria`, `ID_Proveedor`; `Codigo_Barras` → `ID_Producto` | ✔ | ✔ | ✔ |
| `FACTURAS_ENCABEZADO` | `ID_Factura` → `Numero_Factura`, `Fecha_Emision`, `Subtotal_Factura`, `Impuesto_IVA`, `Total_Factura`, `Estado`, `ID_Cliente`, `ID_Empleado`; `Numero_Factura` → `ID_Factura` | ✔ | ✔ | ✔ (ver sección 3) |
| `FACTURAS_DETALLE` | `ID_Detalle` → `ID_Factura`, `ID_Producto`, `Cantidad`, `Precio_Unitario`, `Subtotal` | ✔ | ✔ | ✔ |
| `PAGOS_FACTURA` | `ID_Pago` → `Monto_Pagado`, `Fecha_Pago`, `Numero_Transaccion`, `ID_Factura`, `ID_Metodo_Pago` | ✔ | ✔ | ✔ |
| `ORDENES_COMPRA` | `ID_Orden_Compra` → `Numero_Orden`, `Fecha_Orden`, `Total_Compra`, `Estado_Orden`, `ID_Proveedor`, `ID_Sucursal`; `Numero_Orden` → `ID_Orden_Compra` | ✔ | ✔ | ✔ (ver sección 3) |
| `ORDENES_COMPRA_DETALLE` | `ID_Orden_Detalle` → todos los atributos; (`ID_Orden_Compra`, `ID_Producto`) → `Cantidad`, `Precio_Compra_Unitario`, `Subtotal` | ✔ | ✔ | ✔ |
| `MOVIMIENTOS_INVENTARIO` | `ID_Movimiento` → `ID_Producto`, `Fecha_Movimiento`, `Tipo_Movimiento`, `Cantidad`, `Saldo_Resultante`, `Motivo`, `ID_Factura`, `ID_Orden_Compra` | ✔ | ✔ | ✔ (ver sección 3) |

### Evidencia de 1FN

- Todos los campos contienen un único valor: no hay listas de productos ni teléfonos múltiples en una misma columna.
- No existen grupos repetidos (`Producto1`, `Producto2`…); las líneas de una factura son filas de `FACTURAS_DETALLE`.
- Todas las tablas tienen llave primaria.

### Evidencia de 2FN

- Las tablas con llave primaria de una sola columna cumplen la 2FN automáticamente.
- En `ORDENES_COMPRA_DETALLE`, la llave natural es compuesta (`ID_Orden_Compra`, `ID_Producto`); sus atributos `Cantidad` y `Precio_Compra_Unitario` dependen de la combinación completa (cuánto se compró de *ese* producto en *esa* orden), no de una sola de las dos columnas.
- El nombre del producto no se repite en el detalle (depende solo de `ID_Producto`); el nombre del cliente no se repite en la factura (depende solo de `ID_Cliente`).

### Evidencia de 3FN

Atributos que *podrían* haberse colocado en una tabla incorrecta y cómo se evitó la dependencia transitiva:

| Dato | Dónde se guarda | Dependencia transitiva evitada |
|------|-----------------|--------------------------------|
| Nombre y dirección del cliente | `CLIENTES` | `ID_Factura` → `ID_Cliente` → `Nombre_Completo` |
| Nombre de la categoría | `CATEGORIAS` | `ID_Producto` → `ID_Categoria` → `Nombre_Categoria` |
| Datos del proveedor | `PROVEEDORES` | `ID_Producto` → `ID_Proveedor` → `Nombre_Empresa` |
| Dirección de la sucursal | `SUCURSALES` | `ID_Empleado` → `ID_Sucursal` → `Direccion` |
| Nombre del rol | `ROLES` | `ID_Usuario` → `ID_Rol` → `Nombre_Rol` |
| Nombre del método de pago | `METODOS_PAGO` | `ID_Pago` → `ID_Metodo_Pago` → `Nombre_Metodo` |

Decisiones de diseño que podrían parecer redundancia pero **no** violan la 3FN:

- **`EMPLEADOS.Cargo` y `USUARIOS.ID_Rol`**: son conceptos distintos. El cargo es el puesto laboral (dato de recursos humanos); el rol es el perfil de permisos en el sistema. Un mismo cargo no determina un rol.
- **`PRODUCTOS.ID_Proveedor` y `ORDENES_COMPRA.ID_Proveedor`**: el primero es el proveedor habitual del producto; el segundo es a quién se compró realmente en esa orden. Pueden diferir.
- **`FACTURAS_DETALLE.Precio_Unitario`**: no es una copia redundante de `PRODUCTOS.Precio_Venta`. Es el precio histórico de esa venta; si el catálogo cambia, la factura emitida no debe cambiar. Depende de la línea de venta, no del producto actual.
- **`FACTURAS_DETALLE.Subtotal` y `ORDENES_COMPRA_DETALLE.Subtotal`**: son columnas **virtuales** (`GENERATED ALWAYS AS ... VIRTUAL`); Oracle las calcula al consultar y no las almacena, por lo que no existe redundancia física.

## 3. Redundancia controlada (columnas derivadas)

Para tres casos se almacenan datos que podrían calcularse a partir de otras tablas. Es una **desnormalización deliberada** que la propia guía del proyecto contempla («total de factura calculado a partir del detalle»; «actualización de stock y total de factura mediante triggers»):

| Columna derivada | Se calcula a partir de | Por qué se almacena | Cómo se garantiza su coherencia |
|------------------|------------------------|---------------------|----------------------------------|
| `FACTURAS_ENCABEZADO.Subtotal_Factura`, `Impuesto_IVA`, `Total_Factura` | `SUM(FACTURAS_DETALLE.Subtotal)` y la tasa del 12 % | Consultar el total de una factura sin recalcularlo cada vez; es el valor legal impreso. | `trg_calc_total_factura` lo actualiza tras cada cambio del detalle y `CK_Fac_Total` verifica `Total = Subtotal + IVA`. |
| `ORDENES_COMPRA.Total_Compra` | `SUM(ORDENES_COMPRA_DETALLE.Subtotal)` | Mismo motivo que la factura. | `trg_calc_total_compra`. |
| `PRODUCTOS.Stock_Actual` | Suma de entradas menos salidas del kárdex | Consultar la existencia en tiempo constante, sin recorrer todo el historial, en cada venta. | `trg_actualizar_stock_venta`, `trg_anular_factura` y `sp_registrar_compra` actualizan el stock y el kárdex en la misma transacción; el último bloque de `05_extras_opcional.sql` verifica que ambos coinciden (debe devolver 0 filas). |
| `MOVIMIENTOS_INVENTARIO.Saldo_Resultante` | Stock tras aplicar el movimiento | Auditar el inventario en cualquier fecha (consulta Q4). | Se escribe junto con el movimiento, dentro de la misma transacción. |

Estas redundancias están controladas por la base de datos, no por la aplicación, por lo que no pueden quedar inconsistentes.

## 4. Conclusión

El modelo cumple 1FN, 2FN y 3FN en su diseño lógico. Las únicas columnas redundantes son las derivadas de la sección 3, mantenidas por triggers y verificadas por restricciones y consultas de coherencia.
