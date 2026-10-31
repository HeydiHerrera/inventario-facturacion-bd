-- ============================================================================
-- 06_verificacion_capturas.sql
-- Consultas para tomar las capturas de evidencia del paso a paso (docs/05_paso_a_paso.md).
-- Ejecutar conectado como PROYECTO_DB DESPUES de los scripts 02, 03, 04 y 05.
--
-- COMO USARLO EN DBEAVER
--   * Cada consulta termina en ';'. Haga clic dentro de UNA consulta y pulse Ctrl+Enter
--     para ejecutar solo esa (NO use Alt+X: ejecutaria todas y quedaria visible la ultima).
--   * Tome la captura con Win+Shift+S y guardela en docs/img/capturas/ con el nombre indicado.
-- ============================================================================


-- ---------------------------------------------------------------------------
-- CAPTURA 01 -> 01_usuario_creado.png
-- Usuario conectado, base de datos y version del motor.
-- ---------------------------------------------------------------------------
SELECT USER AS usuario,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS base_datos,
       (SELECT banner FROM v$version WHERE ROWNUM = 1) AS version_oracle,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') AS fecha_hora
  FROM DUAL;


-- ---------------------------------------------------------------------------
-- CAPTURA 02 -> 02_tablas_creadas.png
-- Debe mostrar 15 tablas.
-- ---------------------------------------------------------------------------
SELECT table_name FROM user_tables ORDER BY table_name;


-- ---------------------------------------------------------------------------
-- CAPTURA 03 -> 03_conteo_registros.png
-- Debe mostrar: CATEGORIAS 8, ROLES 5, METODOS_PAGO 5, SUCURSALES 5, PROVEEDORES 15,
-- CLIENTES 16, EMPLEADOS 15, USUARIOS 15, PRODUCTOS 32, FACTURAS_ENCABEZADO 14,
-- FACTURAS_DETALLE 32, PAGOS_FACTURA 13, ORDENES_COMPRA 14, ORDENES_COMPRA_DETALLE 21,
-- MOVIMIENTOS_INVENTARIO 82.
-- ---------------------------------------------------------------------------
SELECT 'CATEGORIAS' AS Tabla, COUNT(*) AS Registros FROM CATEGORIAS UNION ALL
SELECT 'ROLES', COUNT(*) FROM ROLES UNION ALL
SELECT 'METODOS_PAGO', COUNT(*) FROM METODOS_PAGO UNION ALL
SELECT 'SUCURSALES', COUNT(*) FROM SUCURSALES UNION ALL
SELECT 'PROVEEDORES', COUNT(*) FROM PROVEEDORES UNION ALL
SELECT 'CLIENTES', COUNT(*) FROM CLIENTES UNION ALL
SELECT 'EMPLEADOS', COUNT(*) FROM EMPLEADOS UNION ALL
SELECT 'USUARIOS', COUNT(*) FROM USUARIOS UNION ALL
SELECT 'PRODUCTOS', COUNT(*) FROM PRODUCTOS UNION ALL
SELECT 'FACTURAS_ENCABEZADO', COUNT(*) FROM FACTURAS_ENCABEZADO UNION ALL
SELECT 'FACTURAS_DETALLE', COUNT(*) FROM FACTURAS_DETALLE UNION ALL
SELECT 'PAGOS_FACTURA', COUNT(*) FROM PAGOS_FACTURA UNION ALL
SELECT 'ORDENES_COMPRA', COUNT(*) FROM ORDENES_COMPRA UNION ALL
SELECT 'ORDENES_COMPRA_DETALLE', COUNT(*) FROM ORDENES_COMPRA_DETALLE UNION ALL
SELECT 'MOVIMIENTOS_INVENTARIO', COUNT(*) FROM MOVIMIENTOS_INVENTARIO;


-- ---------------------------------------------------------------------------
-- CAPTURA 04 -> 04_bajo_stock_q9.png
-- Q9. Productos con bajo stock (deben ser 8).
-- ---------------------------------------------------------------------------
SELECT p.Codigo_Barras,
       p.Nombre_Producto,
       p.Stock_Actual,
       p.Stock_Minimo,
       p.Stock_Minimo - p.Stock_Actual AS Faltante_Para_Minimo
  FROM PRODUCTOS p
 WHERE p.Stock_Actual <= p.Stock_Minimo
 ORDER BY Faltante_Para_Minimo DESC, p.Nombre_Producto;


-- ---------------------------------------------------------------------------
-- CAPTURA 05 -> 05_factura_completa_q11.png
-- Q11. Factura completa: encabezado, cliente y detalle linea por linea.
-- ---------------------------------------------------------------------------
SELECT f.Numero_Factura,
       f.Fecha_Emision,
       f.Estado,
       c.NIT,
       c.Nombre_Completo      AS Cliente,
       e.Nombre_Completo      AS Atendido_Por,
       d.ID_Detalle           AS Linea,
       p.Nombre_Producto,
       d.Cantidad,
       d.Precio_Unitario,
       d.Subtotal             AS Subtotal_Linea,
       f.Subtotal_Factura,
       f.Impuesto_IVA,
       f.Total_Factura
  FROM FACTURAS_ENCABEZADO f
 INNER JOIN CLIENTES c          ON c.ID_Cliente  = f.ID_Cliente
 INNER JOIN EMPLEADOS e         ON e.ID_Empleado = f.ID_Empleado
 INNER JOIN FACTURAS_DETALLE d  ON d.ID_Factura  = f.ID_Factura
 INNER JOIN PRODUCTOS p         ON p.ID_Producto = d.ID_Producto
 WHERE f.Numero_Factura = 'FACT-2026-00004'
 ORDER BY d.ID_Detalle;


-- ---------------------------------------------------------------------------
-- CAPTURA 06 -> 06_ventas_cliente_q2.png
-- Q2. Ventas totales por cliente.
-- ---------------------------------------------------------------------------
SELECT c.NIT,
       c.Nombre_Completo,
       COUNT(f.ID_Factura)                    AS Frecuencia_Compra,
       NVL(SUM(f.Total_Factura), 0)           AS Total_Acumulado,
       NVL(ROUND(AVG(f.Total_Factura), 2), 0) AS Promedio_Compra,
       MAX(f.Fecha_Emision)                   AS Ultima_Compra
  FROM CLIENTES c
  LEFT JOIN FACTURAS_ENCABEZADO f
         ON f.ID_Cliente = c.ID_Cliente
        AND f.Estado <> 'ANULADO'
 GROUP BY c.NIT, c.Nombre_Completo
 ORDER BY Total_Acumulado DESC, c.Nombre_Completo;


-- ---------------------------------------------------------------------------
-- CAPTURA 07 -> 07_triggers_validos.png
-- Debe mostrar 5 triggers, 3 procedimientos, 2 vistas y 4 tipos, todos en estado VALID.
-- ---------------------------------------------------------------------------
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_type IN ('TRIGGER', 'PROCEDURE', 'VIEW', 'TYPE')
 ORDER BY object_type, object_name;


-- ---------------------------------------------------------------------------
-- CAPTURA 08 -> 08_pruebas_dbms_output.png
-- NO esta en este archivo: ejecute 05_extras_opcional.sql completo con Alt+X,
-- abra el panel Salida (Ctrl+Shift+O) y capture las 12 lineas "PRUEBA ... OK".
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- EXTRA -> coherencia kardex vs stock (debe devolver 0 filas)
-- ---------------------------------------------------------------------------
SELECT p.ID_Producto, p.Nombre_Producto, p.Stock_Actual
  FROM PRODUCTOS p
 WHERE p.Stock_Actual <> (SELECT m.Saldo_Resultante
                            FROM MOVIMIENTOS_INVENTARIO m
                           WHERE m.ID_Movimiento = (SELECT MAX(m2.ID_Movimiento)
                                                      FROM MOVIMIENTOS_INVENTARIO m2
                                                     WHERE m2.ID_Producto = p.ID_Producto));
