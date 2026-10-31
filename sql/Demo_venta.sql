SELECT ID_Producto, Nombre_Producto, Precio_Venta, Stock_Actual
  FROM PRODUCTOS
 WHERE ID_Producto IN (5, 6)
 ORDER BY ID_Producto;

-- ----------------------------------------------------------------------------
-- PASO 2. Hacer la venta
-- Cliente 1, empleado 1, metodo de pago 1.
-- Lineas: 2 unidades del producto 5 (Bombillo) y 1 del producto 6 (Tomacorriente).
-- sp_registrar_factura valida y crea la factura; al insertar cada linea se
-- disparan trg_validar_stock_venta y trg_actualizar_stock_venta.
-- Resultado esperado en Salida: Subtotal Q50, IVA Q6, Total Q56.
-- ----------------------------------------------------------------------------
DECLARE
    v_id  NUMBER;
    v_sub NUMBER;
    v_iva NUMBER;
    v_tot NUMBER;
BEGIN
    sp_registrar_factura(
        1, 1, 1,
        t_lineas_factura(t_linea_factura(5, 2), t_linea_factura(6, 1)),
        SYSDATE,
        v_id, v_sub, v_iva, v_tot);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('VENTA REGISTRADA -> Factura ID ' || v_id ||
                         ' | Subtotal Q' || v_sub ||
                         ' | IVA Q' || v_iva ||
                         ' | Total Q' || v_tot);
END;

-- ----------------------------------------------------------------------------
-- PASO 3. Stock DESPUES de la venta
-- Resultado esperado: Bombillo 280 -> 278, Tomacorriente 186 -> 185
-- ----------------------------------------------------------------------------
SELECT ID_Producto, Nombre_Producto, Precio_Venta, Stock_Actual
  FROM PRODUCTOS
 WHERE ID_Producto IN (5, 6)
 ORDER BY ID_Producto;


-- ----------------------------------------------------------------------------
-- PASO 4. Evidencia en el kardex (MOVIMIENTOS_INVENTARIO)
-- Resultado esperado: 2 filas SALIDA con su saldo resultante.
-- ----------------------------------------------------------------------------
SELECT m.ID_Movimiento,
       p.Nombre_Producto,
       m.Tipo_Movimiento,
       m.Cantidad,
       m.Saldo_Resultante,
       m.Motivo
  FROM MOVIMIENTOS_INVENTARIO m
  JOIN PRODUCTOS p ON p.ID_Producto = m.ID_Producto
 WHERE m.ID_Factura = (SELECT MAX(ID_Factura) FROM FACTURAS_ENCABEZADO)
 ORDER BY m.ID_Movimiento;


-- ----------------------------------------------------------------------------
-- PASO 5. La factura generada
-- Resultado esperado: estado PAGADO, dos lineas, total Q56.
-- ----------------------------------------------------------------------------
SELECT f.Numero_Factura,
       f.Estado,
       p.Nombre_Producto,
       d.Cantidad,
       d.Precio_Unitario,
       d.Subtotal       AS Subtotal_Linea,
       f.Subtotal_Factura,
       f.Impuesto_IVA,
       f.Total_Factura
  FROM FACTURAS_ENCABEZADO f
  JOIN FACTURAS_DETALLE d ON d.ID_Factura  = f.ID_Factura
  JOIN PRODUCTOS p        ON p.ID_Producto = d.ID_Producto
 WHERE f.ID_Factura = (SELECT MAX(ID_Factura) FROM FACTURAS_ENCABEZADO)
 ORDER BY d.ID_Detalle;
