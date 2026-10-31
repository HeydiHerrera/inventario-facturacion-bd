-- ============================================================================
-- 04_consultas_reportes.sql
-- Consultas y reportes del Sistema de Inventario y Facturacion.
-- Ejecutar DESPUES de 03_dml_datos_prueba.sql. Son consultas de solo lectura.
--
-- COBERTURA DE LOS REPORTES MINIMOS DE LA GUIA (seccion 6.4)
--   Productos con bajo stock .......................... Q9
--   Productos con su categoria y proveedor (JOIN) ..... Q10
--   Factura completa (encabezado, cliente, detalle) ... Q11
--   Ventas totales por cliente ........................ Q2
--   Ventas por producto (cantidad e ingreso) .......... Q1
--   Compras / inventario valorizado por proveedor ..... Q3 y Q12
--   Productos nunca vendidos .......................... Q13
--   Ventas por rango de fechas (dia y mes) ............ Q14
--   Consulta con subconsulta .......................... Q13 y Q15
--   Consulta con agregacion y HAVING .................. Q1, Q3, Q6, Q7, Q15
-- ============================================================================
-- Verificacion de carga masiva
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

-- Q1. VENTAS POR PRODUCTO (Top 10, de mayor a menor)
-- Proposito: cantidad vendida e ingreso generado por producto en el periodo, ordenado de
--            mayor a menor. Usa agregacion (SUM, COUNT) y HAVING para ignorar ventas menores a 5 unidades.
SELECT p.Codigo_Barras,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       SUM(d.Cantidad)               AS Unidades_Vendidas,
       SUM(d.Subtotal)               AS Monto_Generado,
       COUNT(DISTINCT f.ID_Factura)  AS Num_Facturas
  FROM FACTURAS_DETALLE d
 INNER JOIN FACTURAS_ENCABEZADO f ON f.ID_Factura  = d.ID_Factura
 INNER JOIN PRODUCTOS p           ON p.ID_Producto = d.ID_Producto
 INNER JOIN CATEGORIAS c          ON c.ID_Categoria = p.ID_Categoria
 WHERE f.Fecha_Emision BETWEEN DATE '2026-09-01' AND DATE '2026-10-31'
   AND f.Estado <> 'ANULADO'
 GROUP BY p.Codigo_Barras, p.Nombre_Producto, c.Nombre_Categoria
HAVING SUM(d.Cantidad) >= 5
 ORDER BY Unidades_Vendidas DESC, Monto_Generado DESC
 FETCH FIRST 10 ROWS ONLY;

-- Q2. VENTAS TOTALES POR CLIENTE
-- Proposito: frecuencia de compra, total acumulado, ticket promedio y ultima compra de cada cliente
--            (LEFT JOIN: incluye clientes sin compras).
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

-- Q3. COMPRAS POR PROVEEDOR Y CATEGORIA
-- Proposito: monto y unidades comprados a cada proveedor (ordenes RECIBIDAS), con precio promedio.
--            Agregacion con HAVING.
SELECT pr.Nombre_Empresa                         AS Proveedor,
       cat.Nombre_Categoria                      AS Categoria,
       COUNT(DISTINCT oc.ID_Orden_Compra)        AS Num_Ordenes,
       SUM(ocd.Cantidad)                         AS Unidades_Compradas,
       SUM(ocd.Subtotal)                         AS Monto_Total,
       ROUND(AVG(ocd.Precio_Compra_Unitario), 2) AS Precio_Promedio
  FROM ORDENES_COMPRA oc
 INNER JOIN PROVEEDORES pr             ON pr.ID_Proveedor     = oc.ID_Proveedor
 INNER JOIN ORDENES_COMPRA_DETALLE ocd ON ocd.ID_Orden_Compra = oc.ID_Orden_Compra
 INNER JOIN PRODUCTOS p                ON p.ID_Producto       = ocd.ID_Producto
 INNER JOIN CATEGORIAS cat             ON cat.ID_Categoria    = p.ID_Categoria
 WHERE oc.Estado_Orden = 'RECIBIDA'
 GROUP BY pr.Nombre_Empresa, cat.Nombre_Categoria
HAVING SUM(ocd.Subtotal) > 0
 ORDER BY pr.Nombre_Empresa, Monto_Total DESC;

-- Q4. KARDEX DEL PRODUCTO BARR-001
-- Proposito: historial de entradas y salidas con saldo acumulado (funcion analitica SUM OVER)
--            comparado contra el saldo registrado. Ambos saldos deben coincidir.
SELECT p.Codigo_Barras,
       p.Nombre_Producto,
       TO_CHAR(m.Fecha_Movimiento, 'YYYY-MM-DD') AS Fecha,
       m.Tipo_Movimiento,
       m.Motivo,
       CASE WHEN m.Tipo_Movimiento = 'ENTRADA' THEN m.Cantidad ELSE 0 END AS Entradas,
       CASE WHEN m.Tipo_Movimiento = 'SALIDA'  THEN m.Cantidad ELSE 0 END AS Salidas,
       SUM(CASE WHEN m.Tipo_Movimiento = 'ENTRADA' THEN m.Cantidad ELSE -m.Cantidad END)
           OVER (PARTITION BY m.ID_Producto
                 ORDER BY m.Fecha_Movimiento, m.ID_Movimiento
                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Saldo_Calculado,
       m.Saldo_Resultante AS Saldo_Registrado
  FROM MOVIMIENTOS_INVENTARIO m
 INNER JOIN PRODUCTOS p ON p.ID_Producto = m.ID_Producto
 WHERE p.Codigo_Barras = 'BARR-001'
 ORDER BY m.Fecha_Movimiento, m.ID_Movimiento;

-- Q5. CIERRE DE CAJA POR FORMA DE PAGO
-- Proposito: total cobrado, promedio y porcentaje del total por metodo de pago en el periodo.
SELECT mp.Nombre_Metodo,
       COUNT(pg.ID_Pago)                          AS Num_Pagos,
       NVL(SUM(pg.Monto_Pagado), 0)               AS Total_Cobrado,
       NVL(ROUND(AVG(pg.Monto_Pagado), 2), 0)     AS Promedio_Por_Pago,
       NVL(MAX(pg.Monto_Pagado), 0)               AS Mayor_Pago,
       NVL(MIN(pg.Monto_Pagado), 0)               AS Menor_Pago,
       ROUND(100 * NVL(SUM(pg.Monto_Pagado), 0)
             / NULLIF(SUM(SUM(pg.Monto_Pagado)) OVER (), 0), 2) AS Porcentaje_Del_Total
  FROM METODOS_PAGO mp
  LEFT JOIN PAGOS_FACTURA pg
         ON pg.ID_Metodo_Pago = mp.ID_Metodo_Pago
        AND pg.Fecha_Pago BETWEEN DATE '2026-09-01' AND DATE '2026-10-31'
 GROUP BY mp.Nombre_Metodo
 ORDER BY Total_Cobrado DESC;

-- Q6. FACTURAS CON SALDO PENDIENTE DE COBRO
-- Proposito: facturas cuyo total supera lo pagado (HAVING sobre la diferencia).
SELECT f.Numero_Factura,
       c.Nombre_Completo AS Cliente,
       f.Fecha_Emision,
       f.Total_Factura,
       NVL(SUM(pg.Monto_Pagado), 0)                   AS Total_Pagado,
       f.Total_Factura - NVL(SUM(pg.Monto_Pagado), 0) AS Saldo_Pendiente
  FROM FACTURAS_ENCABEZADO f
 INNER JOIN CLIENTES c       ON c.ID_Cliente = f.ID_Cliente
  LEFT JOIN PAGOS_FACTURA pg ON pg.ID_Factura = f.ID_Factura
 WHERE f.Estado <> 'ANULADO'
 GROUP BY f.Numero_Factura, c.Nombre_Completo, f.Fecha_Emision, f.Total_Factura
HAVING f.Total_Factura - NVL(SUM(pg.Monto_Pagado), 0) > 0
 ORDER BY Saldo_Pendiente DESC;

-- Q7. VENTAS POR SUCURSAL Y EMPLEADO
-- Proposito: desempeno de vendedores por sucursal; HAVING filtra a quienes vendieron mas de Q100.
SELECT s.Nombre_Sucursal,
       e.Nombre_Completo              AS Empleado,
       COUNT(f.ID_Factura)            AS Num_Facturas,
       SUM(f.Total_Factura)           AS Total_Vendido,
       ROUND(AVG(f.Total_Factura), 2) AS Ticket_Promedio,
       MAX(f.Total_Factura)           AS Venta_Mayor,
       MIN(f.Total_Factura)           AS Venta_Menor
  FROM FACTURAS_ENCABEZADO f
 INNER JOIN EMPLEADOS e  ON e.ID_Empleado = f.ID_Empleado
 INNER JOIN SUCURSALES s ON s.ID_Sucursal = e.ID_Sucursal
 WHERE f.Estado <> 'ANULADO'
 GROUP BY s.Nombre_Sucursal, e.Nombre_Completo
HAVING SUM(f.Total_Factura) > 100
 ORDER BY Total_Vendido DESC;

-- Q8. PROVEEDORES CON Y SIN ORDENES DE COMPRA
-- Proposito: detectar proveedores sin actividad de compra (LEFT JOIN).
SELECT pr.Nombre_Empresa,
       pr.Contacto_Principal,
       COUNT(oc.ID_Orden_Compra)    AS Num_Ordenes,
       NVL(SUM(oc.Total_Compra), 0) AS Monto_Total_Ordenes,
       MAX(oc.Fecha_Orden)          AS Ultima_Orden
  FROM PROVEEDORES pr
  LEFT JOIN ORDENES_COMPRA oc ON oc.ID_Proveedor = pr.ID_Proveedor
 GROUP BY pr.Nombre_Empresa, pr.Contacto_Principal
 ORDER BY Num_Ordenes DESC, pr.Nombre_Empresa;


-- Q9. PRODUCTOS CON BAJO STOCK
-- Proposito: listar los productos cuyo stock actual esta en o por debajo del minimo definido,
--            para decidir que reponer. El faltante indica cuantas unidades faltan para el minimo.
SELECT p.Codigo_Barras,
       p.Nombre_Producto,
       p.Stock_Actual,
       p.Stock_Minimo,
       p.Stock_Minimo - p.Stock_Actual AS Faltante_Para_Minimo
  FROM PRODUCTOS p
 WHERE p.Stock_Actual <= p.Stock_Minimo
 ORDER BY Faltante_Para_Minimo DESC, p.Nombre_Producto;

-- Q10. LISTADO DE PRODUCTOS CON SU CATEGORIA Y PROVEEDOR (JOIN)
-- Proposito: catalogo completo de inventario con precios, margen de ganancia y datos de origen.
SELECT p.Codigo_Barras,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       pr.Nombre_Empresa                    AS Proveedor,
       p.Precio_Compra,
       p.Precio_Venta,
       p.Precio_Venta - p.Precio_Compra     AS Margen_Unitario,
       p.Stock_Actual
  FROM PRODUCTOS p
 INNER JOIN CATEGORIAS  c  ON c.ID_Categoria = p.ID_Categoria
 INNER JOIN PROVEEDORES pr ON pr.ID_Proveedor = p.ID_Proveedor
 ORDER BY c.Nombre_Categoria, p.Nombre_Producto;

-- Q11. FACTURA COMPLETA: ENCABEZADO, CLIENTE Y DETALLE LINEA POR LINEA
-- Proposito: reproducir una factura impresa con cliente, vendedor, lineas y subtotales.
-- Para consultar otra factura, cambie el numero en el WHERE (por ejemplo 'FACT-2026-00012').
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

-- Q12. INVENTARIO VALORIZADO POR PROVEEDOR
-- Proposito: capital inmovilizado en existencias por proveedor, a precio de compra (costo)
--            y a precio de venta (ingreso potencial).
SELECT pr.Nombre_Empresa                         AS Proveedor,
       COUNT(p.ID_Producto)                      AS Num_Productos,
       NVL(SUM(p.Stock_Actual), 0)               AS Unidades_En_Stock,
       NVL(SUM(p.Stock_Actual * p.Precio_Compra), 0) AS Valor_A_Costo,
       NVL(SUM(p.Stock_Actual * p.Precio_Venta), 0)  AS Valor_A_Precio_Venta
  FROM PROVEEDORES pr
  LEFT JOIN PRODUCTOS p ON p.ID_Proveedor = pr.ID_Proveedor
 GROUP BY pr.Nombre_Empresa
 ORDER BY Valor_A_Costo DESC, pr.Nombre_Empresa;

-- Q13. PRODUCTOS NUNCA VENDIDOS (subconsulta con NOT EXISTS)
-- Proposito: identificar productos sin ninguna venta para evaluar liquidacion o dejar de comprarlos.
SELECT p.Codigo_Barras,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       p.Stock_Actual,
       p.Stock_Actual * p.Precio_Compra AS Capital_Inmovilizado
  FROM PRODUCTOS p
 INNER JOIN CATEGORIAS c ON c.ID_Categoria = p.ID_Categoria
 WHERE NOT EXISTS (SELECT 1
                     FROM FACTURAS_DETALLE d
                    WHERE d.ID_Producto = p.ID_Producto)
 ORDER BY Capital_Inmovilizado DESC;

-- Q14a. VENTAS POR MES
-- Proposito: facturacion mensual (subtotal, IVA y total) dentro de un rango de fechas.
SELECT TO_CHAR(f.Fecha_Emision, 'YYYY-MM') AS Mes,
       COUNT(*)                            AS Num_Facturas,
       SUM(f.Subtotal_Factura)             AS Subtotal,
       SUM(f.Impuesto_IVA)                 AS IVA,
       SUM(f.Total_Factura)                AS Total
  FROM FACTURAS_ENCABEZADO f
 WHERE f.Estado <> 'ANULADO'
   AND f.Fecha_Emision BETWEEN DATE '2026-09-01' AND DATE '2026-10-31'
 GROUP BY TO_CHAR(f.Fecha_Emision, 'YYYY-MM')
 ORDER BY Mes;

-- Q14b. VENTAS POR DIA
-- Proposito: detalle diario de ventas dentro de un rango de fechas (cambie las fechas del BETWEEN).
SELECT TRUNC(f.Fecha_Emision)  AS Dia,
       COUNT(*)                AS Num_Facturas,
       SUM(f.Total_Factura)    AS Total_Vendido
  FROM FACTURAS_ENCABEZADO f
 WHERE f.Estado <> 'ANULADO'
   AND f.Fecha_Emision BETWEEN DATE '2026-10-01' AND DATE '2026-10-31'
 GROUP BY TRUNC(f.Fecha_Emision)
 ORDER BY Dia;

-- Q15. CLIENTES CON COMPRAS SUPERIORES AL PROMEDIO (subconsulta + HAVING)
-- Proposito: identificar a los clientes mas valiosos: aquellos cuyo total comprado supera el
--            promedio de venta por factura de todo el negocio.
SELECT c.Nombre_Completo,
       COUNT(f.ID_Factura)  AS Num_Facturas,
       SUM(f.Total_Factura) AS Total_Comprado
  FROM CLIENTES c
 INNER JOIN FACTURAS_ENCABEZADO f ON f.ID_Cliente = c.ID_Cliente
 WHERE f.Estado <> 'ANULADO'
 GROUP BY c.Nombre_Completo
HAVING SUM(f.Total_Factura) > (SELECT AVG(Total_Factura)
                                 FROM FACTURAS_ENCABEZADO
                                WHERE Estado <> 'ANULADO')
 ORDER BY Total_Comprado DESC;
