-- ============================================================================
-- 05_extras_opcional.sql
-- LOGICA PROGRAMADA: tipos, procedimientos, triggers, vistas y pruebas.
-- Ejecutar DESPUES de 03_dml_datos_prueba.sql (y de 04_consultas_reportes.sql).
-- Escrito para DBeaver: no usa '/' al final de los bloques PL/SQL. En SQL*Plus agregue '/' tras cada bloque.
-- En DBeaver: ejecutar con 'Ejecutar script' (Alt+X). Los mensajes de las pruebas aparecen
-- en el panel 'Salida' (Ctrl+Shift+O).
--
-- REGLAS DE NEGOCIO QUE IMPLEMENTA ESTE SCRIPT
--   V1. No se puede vender mas unidades que el stock disponible.
--   V2. Solo se puede agregar, modificar o quitar lineas en facturas PENDIENTES.
--   V3. El producto de la linea debe existir.
--   V4. No se puede vender un producto por debajo de su precio de compra.
--   S1. Cada linea de venta DESCUENTA el stock y registra una SALIDA en el kardex.
--   S2. Modificar la cantidad o eliminar una linea AJUSTA el stock automaticamente.
--   S3. Anular una factura DEVUELVE el stock y registra las ENTRADAS en el kardex.
--   S4. Una factura ANULADA no puede reactivarse.
--   T1. Subtotal, IVA (12 %) y total de la factura se recalculan desde el detalle.
--   T2. El total de la orden de compra se recalcula desde su detalle.
-- ============================================================================

-- ============================================================================
-- 5.1 TIPOS PARA PARAMETROS DE COLECCION
-- ============================================================================
-- Elimina tipos de una ejecucion anterior (primero las colecciones, luego los objetos).
-- Evita ORA-02303 al volver a ejecutar este script.
BEGIN EXECUTE IMMEDIATE 'DROP TYPE t_lineas_factura FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;

BEGIN EXECUTE IMMEDIATE 'DROP TYPE t_linea_factura FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;

BEGIN EXECUTE IMMEDIATE 'DROP TYPE t_lineas_compra FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;

BEGIN EXECUTE IMMEDIATE 'DROP TYPE t_linea_compra FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;

CREATE OR REPLACE TYPE t_linea_factura AS OBJECT (
    id_producto NUMBER,
    cantidad    NUMBER
);

CREATE OR REPLACE TYPE t_lineas_factura AS TABLE OF t_linea_factura;

CREATE OR REPLACE TYPE t_linea_compra AS OBJECT (
    id_producto     NUMBER,
    cantidad        NUMBER,
    precio_unitario NUMBER
);

CREATE OR REPLACE TYPE t_lineas_compra AS TABLE OF t_linea_compra;


-- ============================================================================
-- 5.2 TRIGGERS DE VENTA: VERIFICACION Y ACTUALIZACION DE STOCK
--     (se crean antes que los procedimientos porque estos dependen de ellos
--      para descontar el inventario)
-- ============================================================================

-- ---------- 5.2.1 VERIFICACION cuando se hace una venta (V1, V2, V3, V4) ----------
-- Se dispara ANTES de insertar, modificar o eliminar una linea de factura.
-- Si alguna regla falla, la linea se rechaza y NO se toca el inventario.
CREATE OR REPLACE TRIGGER trg_validar_stock_venta
BEFORE INSERT OR UPDATE OR DELETE ON FACTURAS_DETALLE
FOR EACH ROW
DECLARE
    v_id_factura FACTURAS_ENCABEZADO.ID_Factura%TYPE;
    v_numero     FACTURAS_ENCABEZADO.Numero_Factura%TYPE;
    v_estado     FACTURAS_ENCABEZADO.Estado%TYPE;
    v_stock      PRODUCTOS.Stock_Actual%TYPE;
    v_nombre     PRODUCTOS.Nombre_Producto%TYPE;
    v_costo      PRODUCTOS.Precio_Compra%TYPE;
    v_disponible NUMBER;
BEGIN
    IF DELETING THEN
        v_id_factura := :OLD.ID_Factura;
    ELSE
        v_id_factura := :NEW.ID_Factura;
    END IF;

    -- V2: la factura debe estar abierta (PENDIENTE)
    BEGIN
        SELECT Numero_Factura, Estado
          INTO v_numero, v_estado
          FROM FACTURAS_ENCABEZADO
         WHERE ID_Factura = v_id_factura;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20006, 'La factura ' || v_id_factura || ' no existe.');
    END;

    IF v_estado <> 'PENDIENTE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'La factura ' || v_numero || ' esta ' || v_estado ||
            ' y no admite cambios en su detalle.');
    END IF;

    IF NOT DELETING THEN
        -- V3: el producto debe existir
        BEGIN
            SELECT Stock_Actual, Nombre_Producto, Precio_Compra
              INTO v_stock, v_nombre, v_costo
              FROM PRODUCTOS
             WHERE ID_Producto = :NEW.ID_Producto;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20003, 'El producto ' || :NEW.ID_Producto || ' no existe.');
        END;

        -- V1: stock suficiente. Si se edita una linea del mismo producto, la cantidad
        --     anterior ya fue descontada, por lo que se suma de nuevo al disponible.
        v_disponible := v_stock;
        IF UPDATING AND :OLD.ID_Producto = :NEW.ID_Producto THEN
            v_disponible := v_stock + :OLD.Cantidad;
        END IF;

        IF :NEW.Cantidad > v_disponible THEN
            RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente para "' || v_nombre ||
                '": solicitado ' || :NEW.Cantidad || ', disponible ' || v_disponible || '.');
        END IF;

        -- V4: no vender por debajo del costo
        IF :NEW.Precio_Unitario < v_costo THEN
            RAISE_APPLICATION_ERROR(-20005, 'Precio por debajo del costo para "' || v_nombre ||
                '": precio ' || :NEW.Precio_Unitario || ', costo ' || v_costo || '.');
        END IF;
    END IF;
END trg_validar_stock_venta;

-- ---------- 5.2.2 ACTUALIZACION DEL STOCK cuando se hace una venta (S1, S2) ----------
-- Procedimiento auxiliar: aplica un movimiento al stock del producto y lo registra en el kardex.
CREATE OR REPLACE PROCEDURE sp_mover_stock_venta (
    p_producto   IN NUMBER,
    p_cantidad   IN NUMBER,
    p_tipo       IN VARCHAR2,
    p_fecha_mov  IN DATE,
    p_motivo     IN VARCHAR2,
    p_id_factura IN NUMBER,
    p_numero     IN VARCHAR2
) AS
    v_saldo PRODUCTOS.Stock_Actual%TYPE;
BEGIN
    IF p_tipo = 'SALIDA' THEN
        UPDATE PRODUCTOS SET Stock_Actual = Stock_Actual - p_cantidad
         WHERE ID_Producto = p_producto
        RETURNING Stock_Actual INTO v_saldo;
    ELSE
        UPDATE PRODUCTOS SET Stock_Actual = Stock_Actual + p_cantidad
         WHERE ID_Producto = p_producto
        RETURNING Stock_Actual INTO v_saldo;
    END IF;
    INSERT INTO MOVIMIENTOS_INVENTARIO
        (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura)
    VALUES
        (p_producto, p_fecha_mov, p_tipo, p_cantidad, v_saldo, p_motivo || ' ' || p_numero, p_id_factura);
END sp_mover_stock_venta;

-- Se dispara DESPUES de cada linea valida y llama al procedimiento auxiliar:
--   INSERT -> SALIDA por la cantidad vendida
--   UPDATE -> SALIDA o ENTRADA por la diferencia de cantidad (o cambio de producto)
--   DELETE -> ENTRADA que devuelve la cantidad al inventario
CREATE OR REPLACE TRIGGER trg_actualizar_stock_venta
AFTER INSERT OR UPDATE OF Cantidad, ID_Producto OR DELETE ON FACTURAS_DETALLE
FOR EACH ROW
DECLARE
    v_id_factura FACTURAS_ENCABEZADO.ID_Factura%TYPE;
    v_numero     FACTURAS_ENCABEZADO.Numero_Factura%TYPE;
    v_fecha      FACTURAS_ENCABEZADO.Fecha_Emision%TYPE;
    v_dif        NUMBER;
BEGIN
    IF DELETING THEN
        v_id_factura := :OLD.ID_Factura;
    ELSE
        v_id_factura := :NEW.ID_Factura;
    END IF;
    SELECT Numero_Factura, Fecha_Emision INTO v_numero, v_fecha
      FROM FACTURAS_ENCABEZADO WHERE ID_Factura = v_id_factura;
    IF INSERTING THEN
        sp_mover_stock_venta(:NEW.ID_Producto, :NEW.Cantidad, 'SALIDA', v_fecha, 'Venta', v_id_factura, v_numero);
    ELSIF DELETING THEN
        sp_mover_stock_venta(:OLD.ID_Producto, :OLD.Cantidad, 'ENTRADA', SYSDATE, 'Linea eliminada de', v_id_factura, v_numero);
    ELSE
        IF :OLD.ID_Producto = :NEW.ID_Producto THEN
            v_dif := :NEW.Cantidad - :OLD.Cantidad;
            IF v_dif > 0 THEN
                sp_mover_stock_venta(:NEW.ID_Producto, v_dif, 'SALIDA', SYSDATE, 'Ajuste de venta (aumento) en', v_id_factura, v_numero);
            ELSIF v_dif < 0 THEN
                sp_mover_stock_venta(:NEW.ID_Producto, -v_dif, 'ENTRADA', SYSDATE, 'Ajuste de venta (reduccion) en', v_id_factura, v_numero);
            END IF;
        ELSE
            sp_mover_stock_venta(:OLD.ID_Producto, :OLD.Cantidad, 'ENTRADA', SYSDATE, 'Cambio de producto en', v_id_factura, v_numero);
            sp_mover_stock_venta(:NEW.ID_Producto, :NEW.Cantidad, 'SALIDA', SYSDATE, 'Cambio de producto en', v_id_factura, v_numero);
        END IF;
    END IF;
END trg_actualizar_stock_venta;

-- ---------- 5.2.3 ANULACION de factura: devuelve el stock (S3, S4) ----------
CREATE OR REPLACE TRIGGER trg_anular_factura
AFTER UPDATE OF Estado ON FACTURAS_ENCABEZADO
FOR EACH ROW
DECLARE
    v_saldo PRODUCTOS.Stock_Actual%TYPE;
BEGIN
    -- S4: una factura anulada no se reactiva
    IF :OLD.Estado = 'ANULADO' AND :NEW.Estado <> 'ANULADO' THEN
        RAISE_APPLICATION_ERROR(-20004, 'La factura ' || :OLD.Numero_Factura ||
            ' esta anulada y no puede reactivarse.');
    END IF;

    -- S3: al anular, cada linea regresa su cantidad al inventario
    IF :NEW.Estado = 'ANULADO' AND :OLD.Estado <> 'ANULADO' THEN
        FOR r IN (SELECT ID_Producto, Cantidad
                    FROM FACTURAS_DETALLE
                   WHERE ID_Factura = :NEW.ID_Factura) LOOP
            UPDATE PRODUCTOS
               SET Stock_Actual = Stock_Actual + r.Cantidad
             WHERE ID_Producto = r.ID_Producto
            RETURNING Stock_Actual INTO v_saldo;

            INSERT INTO MOVIMIENTOS_INVENTARIO
                (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura)
            VALUES
                (r.ID_Producto, SYSDATE, 'ENTRADA', r.Cantidad, v_saldo,
                 'Anulacion ' || :NEW.Numero_Factura, :NEW.ID_Factura);
        END LOOP;
    END IF;
END trg_anular_factura;


-- ============================================================================
-- 5.3 TRIGGERS DE TOTALES (T1, T2)
-- ============================================================================
-- Mantiene Subtotal, IVA (12 %) y Total de la factura sumando o restando el efecto de cada
-- linea modificada (trigger de fila simple; evita el error de tabla mutante).
CREATE OR REPLACE TRIGGER trg_calc_total_factura
AFTER INSERT OR UPDATE OR DELETE ON FACTURAS_DETALLE
FOR EACH ROW
BEGIN
    IF DELETING OR UPDATING THEN
        UPDATE FACTURAS_ENCABEZADO
           SET Subtotal_Factura = Subtotal_Factura - (:OLD.Cantidad * :OLD.Precio_Unitario),
               Impuesto_IVA     = ROUND((Subtotal_Factura - (:OLD.Cantidad * :OLD.Precio_Unitario)) * 0.12, 2),
               Total_Factura    = (Subtotal_Factura - (:OLD.Cantidad * :OLD.Precio_Unitario))
                                + ROUND((Subtotal_Factura - (:OLD.Cantidad * :OLD.Precio_Unitario)) * 0.12, 2)
         WHERE ID_Factura = :OLD.ID_Factura;
    END IF;
    IF INSERTING OR UPDATING THEN
        UPDATE FACTURAS_ENCABEZADO
           SET Subtotal_Factura = Subtotal_Factura + (:NEW.Cantidad * :NEW.Precio_Unitario),
               Impuesto_IVA     = ROUND((Subtotal_Factura + (:NEW.Cantidad * :NEW.Precio_Unitario)) * 0.12, 2),
               Total_Factura    = (Subtotal_Factura + (:NEW.Cantidad * :NEW.Precio_Unitario))
                                + ROUND((Subtotal_Factura + (:NEW.Cantidad * :NEW.Precio_Unitario)) * 0.12, 2)
         WHERE ID_Factura = :NEW.ID_Factura;
    END IF;
END trg_calc_total_factura;

-- Mantiene Total_Compra de la orden sumando o restando el efecto de cada linea modificada.
CREATE OR REPLACE TRIGGER trg_calc_total_compra
AFTER INSERT OR UPDATE OR DELETE ON ORDENES_COMPRA_DETALLE
FOR EACH ROW
BEGIN
    IF DELETING OR UPDATING THEN
        UPDATE ORDENES_COMPRA
           SET Total_Compra = Total_Compra - (:OLD.Cantidad * :OLD.Precio_Compra_Unitario)
         WHERE ID_Orden_Compra = :OLD.ID_Orden_Compra;
    END IF;
    IF INSERTING OR UPDATING THEN
        UPDATE ORDENES_COMPRA
           SET Total_Compra = Total_Compra + (:NEW.Cantidad * :NEW.Precio_Compra_Unitario)
         WHERE ID_Orden_Compra = :NEW.ID_Orden_Compra;
    END IF;
END trg_calc_total_compra;


-- ============================================================================
-- 5.4 PROCEDIMIENTOS ALMACENADOS
-- ============================================================================

-- ---------- 5.4.1 Registrar una venta completa (factura + detalle + pago) ----------
-- El procedimiento valida los datos y arma la factura. El descuento de stock y el
-- registro en el kardex los realiza trg_actualizar_stock_venta al insertar cada linea.
-- Si cualquier validacion falla, se revierte TODA la factura (ROLLBACK TO SAVEPOINT).
CREATE OR REPLACE PROCEDURE sp_registrar_factura (
    p_id_cliente     IN  NUMBER,
    p_id_empleado    IN  NUMBER,
    p_id_metodo_pago IN  NUMBER,
    p_lineas         IN  t_lineas_factura,
    p_fecha          IN  DATE DEFAULT SYSDATE,
    o_id_factura     OUT NUMBER,
    o_subtotal       OUT NUMBER,
    o_iva            OUT NUMBER,
    o_total          OUT NUMBER
) AS
    c_tasa_iva CONSTANT NUMBER := 0.12;
    v_numero   FACTURAS_ENCABEZADO.Numero_Factura%TYPE;
    v_stock    PRODUCTOS.Stock_Actual%TYPE;
    v_precio   PRODUCTOS.Precio_Venta%TYPE;
    v_nombre   PRODUCTOS.Nombre_Producto%TYPE;
    v_existe   NUMBER;
BEGIN
    SAVEPOINT sp_inicio_factura;
    o_subtotal := 0;

    -- Verificaciones previas de la venta
    IF p_lineas IS NULL OR p_lineas.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'La factura debe tener al menos una linea de detalle.');
    END IF;

    SELECT COUNT(*) INTO v_existe FROM CLIENTES WHERE ID_Cliente = p_id_cliente;
    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'El cliente ' || p_id_cliente || ' no existe.');
    END IF;

    SELECT COUNT(*) INTO v_existe FROM EMPLEADOS WHERE ID_Empleado = p_id_empleado;
    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20015, 'El empleado ' || p_id_empleado || ' no existe.');
    END IF;

    IF p_id_metodo_pago IS NOT NULL THEN
        SELECT COUNT(*) INTO v_existe FROM METODOS_PAGO WHERE ID_Metodo_Pago = p_id_metodo_pago;
        IF v_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20016, 'El metodo de pago ' || p_id_metodo_pago || ' no existe.');
        END IF;
    END IF;

    v_numero := 'FACT-' || TO_CHAR(p_fecha, 'YYYY') || '-' || LPAD(SEQ_NUM_FACTURA.NEXTVAL, 5, '0');

    INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Estado, ID_Cliente, ID_Empleado)
    VALUES (v_numero, p_fecha, 'PENDIENTE', p_id_cliente, p_id_empleado)
    RETURNING ID_Factura INTO o_id_factura;

    FOR i IN 1 .. p_lineas.COUNT LOOP
        IF p_lineas(i).cantidad IS NULL OR p_lineas(i).cantidad <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'La cantidad debe ser mayor a cero (producto ' || p_lineas(i).id_producto || ').');
        END IF;

        -- Se bloquea la fila del producto para que dos ventas simultaneas no compitan por el mismo stock
        BEGIN
            SELECT Stock_Actual, Precio_Venta, Nombre_Producto
              INTO v_stock, v_precio, v_nombre
              FROM PRODUCTOS
             WHERE ID_Producto = p_lineas(i).id_producto
               FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20012, 'El producto ' || p_lineas(i).id_producto || ' no existe.');
        END;

        IF p_lineas(i).cantidad > v_stock THEN
            RAISE_APPLICATION_ERROR(-20013, 'Stock insuficiente para "' || v_nombre ||
                '": solicitado ' || p_lineas(i).cantidad || ', disponible ' || v_stock || '.');
        END IF;

        -- Al insertar la linea, los triggers validan de nuevo, descuentan el stock y escriben el kardex
        INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario)
        VALUES (o_id_factura, p_lineas(i).id_producto, p_lineas(i).cantidad, v_precio);

        o_subtotal := o_subtotal + (p_lineas(i).cantidad * v_precio);
    END LOOP;

    o_iva   := ROUND(o_subtotal * c_tasa_iva, 2);
    o_total := o_subtotal + o_iva;

    UPDATE FACTURAS_ENCABEZADO
       SET Subtotal_Factura = o_subtotal,
           Impuesto_IVA     = o_iva,
           Total_Factura    = o_total,
           Estado           = CASE WHEN p_id_metodo_pago IS NOT NULL THEN 'PAGADO' ELSE 'PENDIENTE' END
     WHERE ID_Factura = o_id_factura;

    IF p_id_metodo_pago IS NOT NULL THEN
        INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago)
        VALUES (o_total, p_fecha, 'TRX-' || LPAD(o_id_factura, 6, '0'), o_id_factura, p_id_metodo_pago);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_inicio_factura;
        RAISE;
END sp_registrar_factura;

-- ---------- 5.4.2 Registrar una compra a proveedor (aumenta stock y kardex) ----------
CREATE OR REPLACE PROCEDURE sp_registrar_compra (
    p_id_proveedor IN  NUMBER,
    p_id_sucursal  IN  NUMBER,
    p_lineas       IN  t_lineas_compra,
    p_fecha        IN  DATE DEFAULT SYSDATE,
    o_id_orden     OUT NUMBER,
    o_total        OUT NUMBER
) AS
    v_numero ORDENES_COMPRA.Numero_Orden%TYPE;
    v_saldo  PRODUCTOS.Stock_Actual%TYPE;
BEGIN
    SAVEPOINT sp_inicio_compra;
    o_total := 0;
    IF p_lineas IS NULL OR p_lineas.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'La orden de compra debe tener al menos una linea de detalle.');
    END IF;

    v_numero := 'OC-' || TO_CHAR(p_fecha, 'YYYY') || '-' || LPAD(SEQ_NUM_ORDEN.NEXTVAL, 4, '0');

    INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal)
    VALUES (v_numero, p_fecha, 0, 'RECIBIDA', p_id_proveedor, p_id_sucursal)
    RETURNING ID_Orden_Compra INTO o_id_orden;

    FOR i IN 1 .. p_lineas.COUNT LOOP
        IF p_lineas(i).cantidad IS NULL OR p_lineas(i).cantidad <= 0
           OR p_lineas(i).precio_unitario IS NULL OR p_lineas(i).precio_unitario <= 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Cantidad y precio deben ser mayores a cero (producto ' || p_lineas(i).id_producto || ').');
        END IF;

        UPDATE PRODUCTOS
           SET Stock_Actual = Stock_Actual + p_lineas(i).cantidad
         WHERE ID_Producto = p_lineas(i).id_producto
        RETURNING Stock_Actual INTO v_saldo;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'El producto ' || p_lineas(i).id_producto || ' no existe.');
        END IF;

        INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario)
        VALUES (o_id_orden, p_lineas(i).id_producto, p_lineas(i).cantidad, p_lineas(i).precio_unitario);

        INSERT INTO MOVIMIENTOS_INVENTARIO
            (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra)
        VALUES
            (p_lineas(i).id_producto, p_fecha, 'ENTRADA', p_lineas(i).cantidad, v_saldo, 'Compra ' || v_numero, o_id_orden);

        o_total := o_total + (p_lineas(i).cantidad * p_lineas(i).precio_unitario);
    END LOOP;

    UPDATE ORDENES_COMPRA SET Total_Compra = o_total WHERE ID_Orden_Compra = o_id_orden;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_inicio_compra;
        RAISE;
END sp_registrar_compra;


-- ============================================================================
-- 5.5 VISTAS ANALITICAS
-- ============================================================================
CREATE OR REPLACE VIEW VW_HISTORIAL_CONSOLIDADO AS
SELECT 'COMPRA'              AS Tipo_Operacion,
       pr.Nombre_Empresa     AS Entidad,
       oc.Numero_Orden       AS Documento,
       oc.Fecha_Orden        AS Fecha,
       oc.Estado_Orden       AS Estado,
       p.Nombre_Producto     AS Detalle,
       ocd.Cantidad          AS Cantidad,
       ocd.Subtotal          AS Monto
  FROM ORDENES_COMPRA oc
 INNER JOIN PROVEEDORES pr             ON pr.ID_Proveedor = oc.ID_Proveedor
 INNER JOIN ORDENES_COMPRA_DETALLE ocd ON ocd.ID_Orden_Compra = oc.ID_Orden_Compra
 INNER JOIN PRODUCTOS p                ON p.ID_Producto = ocd.ID_Producto
UNION ALL
SELECT 'VENTA_ACUMULADA',
       c.Nombre_Completo,
       NVL(v.Facturas, 0) || ' factura(s)',
       v.Ultima_Factura,
       'N/A',
       'Acumulado de ventas al cliente',
       NVL(v.Unidades, 0),
       NVL(v.Total, 0)
  FROM CLIENTES c
  LEFT JOIN (
        SELECT ID_Cliente,
               COUNT(*)            AS Facturas,
               MAX(Fecha_Emision)  AS Ultima_Factura,
               SUM(Unidades)       AS Unidades,
               SUM(Total_Factura)  AS Total
          FROM (SELECT f.ID_Cliente, f.Fecha_Emision, f.Total_Factura,
                       (SELECT NVL(SUM(d.Cantidad), 0) FROM FACTURAS_DETALLE d WHERE d.ID_Factura = f.ID_Factura) AS Unidades
                  FROM FACTURAS_ENCABEZADO f
                 WHERE f.Estado <> 'ANULADO')
         GROUP BY ID_Cliente
       ) v ON v.ID_Cliente = c.ID_Cliente;

CREATE OR REPLACE VIEW VW_INVENTARIO_CRITICO AS
SELECT p.ID_Producto,
       p.Codigo_Barras,
       p.Nombre_Producto,
       c.Nombre_Categoria,
       pr.Nombre_Empresa                 AS Proveedor_Habitual,
       p.Stock_Actual,
       p.Stock_Minimo,
       p.Stock_Minimo - p.Stock_Actual   AS Faltante_Para_Minimo,
       (p.Stock_Minimo * 2) - p.Stock_Actual AS Cantidad_Sugerida_Pedido
  FROM PRODUCTOS p
 INNER JOIN CATEGORIAS c   ON c.ID_Categoria = p.ID_Categoria
 INNER JOIN PROVEEDORES pr ON pr.ID_Proveedor = p.ID_Proveedor
 WHERE p.Stock_Actual <= p.Stock_Minimo;


-- ============================================================================
-- 5.6 PRUEBAS DE FUNCIONAMIENTO (salida por DBMS_OUTPUT)
--     Cada prueba termina con ROLLBACK, por lo que los datos quedan intactos.
--     Resultado esperado: 12 lineas "PRUEBA ... OK" (pruebas 1 a 11; la 11 tiene dos partes: 11a y 11b).
-- ============================================================================

-- Aviso si las tablas estan vacias (falto ejecutar 03_dml_datos_prueba.sql)
DECLARE
    v_n NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_n FROM PRODUCTOS;
    IF v_n = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ATENCION: las tablas estan vacias. Ejecute 02, 03 y luego 05 (en ese orden).');
    END IF;
END;

-- ---- VERIFICACION DE LA VENTA ----

-- Prueba 1: el procedimiento rechaza una venta con stock insuficiente
DECLARE
    v_id NUMBER; v_sub NUMBER; v_iva NUMBER; v_tot NUMBER;
BEGIN
    sp_registrar_factura(1, 1, 1, t_lineas_factura(t_linea_factura(19, 50)), SYSDATE, v_id, v_sub, v_iva, v_tot);
    DBMS_OUTPUT.PUT_LINE('ERROR: la venta no debio permitirse.');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20013 THEN
            DBMS_OUTPUT.PUT_LINE('PRUEBA 1 OK - Rechazado por el procedimiento: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('PRUEBA 1 FALLO - error inesperado: ' || SQLERRM);
        END IF;
END;

-- Prueba 2: el trigger rechaza un INSERT directo que supera las existencias
DECLARE
    v_fac NUMBER;
BEGIN
    SELECT ID_Factura INTO v_fac FROM FACTURAS_ENCABEZADO WHERE Estado = 'PENDIENTE';
    INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (v_fac, 19, 50, 495.00);
    DBMS_OUTPUT.PUT_LINE('ERROR: el trigger no bloqueo la insercion.');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20001 THEN
            DBMS_OUTPUT.PUT_LINE('PRUEBA 2 OK - Rechazado por trg_validar_stock_venta: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('PRUEBA 2 FALLO - error inesperado: ' || SQLERRM);
        END IF;
END;

-- Prueba 3: no se pueden agregar lineas a una factura ya PAGADA
BEGIN
    INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (1, 10, 1, 15.00);
    DBMS_OUTPUT.PUT_LINE('ERROR: se agrego una linea a una factura pagada.');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20002 THEN
            DBMS_OUTPUT.PUT_LINE('PRUEBA 3 OK - Factura cerrada protegida: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('PRUEBA 3 FALLO - error inesperado: ' || SQLERRM);
        END IF;
END;

-- Prueba 4: no se permite vender por debajo del precio de compra
DECLARE
    v_fac NUMBER;
BEGIN
    SELECT ID_Factura INTO v_fac FROM FACTURAS_ENCABEZADO WHERE Estado = 'PENDIENTE';
    INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (v_fac, 10, 1, 5.00);
    DBMS_OUTPUT.PUT_LINE('ERROR: se vendio por debajo del costo.');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20005 THEN
            DBMS_OUTPUT.PUT_LINE('PRUEBA 4 OK - Precio bajo costo rechazado: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('PRUEBA 4 FALLO - error inesperado: ' || SQLERRM);
        END IF;
END;

-- ---- ACTUALIZACION DEL STOCK ----

-- Prueba 5: factura exitosa por procedimiento (descuenta stock, calcula IVA, escribe kardex)
DECLARE
    v_id NUMBER; v_sub NUMBER; v_iva NUMBER; v_tot NUMBER;
    v_antes5 NUMBER; v_desp5 NUMBER; v_antes6 NUMBER; v_desp6 NUMBER; v_kardex NUMBER;
BEGIN
    SELECT Stock_Actual INTO v_antes5 FROM PRODUCTOS WHERE ID_Producto = 5;
    SELECT Stock_Actual INTO v_antes6 FROM PRODUCTOS WHERE ID_Producto = 6;
    sp_registrar_factura(1, 1, 1, t_lineas_factura(t_linea_factura(5, 2), t_linea_factura(6, 1)),
                         SYSDATE, v_id, v_sub, v_iva, v_tot);
    SELECT Stock_Actual INTO v_desp5 FROM PRODUCTOS WHERE ID_Producto = 5;
    SELECT Stock_Actual INTO v_desp6 FROM PRODUCTOS WHERE ID_Producto = 6;
    SELECT COUNT(*) INTO v_kardex FROM MOVIMIENTOS_INVENTARIO WHERE ID_Factura = v_id AND Tipo_Movimiento = 'SALIDA';
    DBMS_OUTPUT.PUT_LINE('PRUEBA 5 OK - Factura ' || v_id || ' subtotal Q' || v_sub || ' IVA Q' || v_iva ||
                         ' total Q' || v_tot);
    DBMS_OUTPUT.PUT_LINE('            Stock Bombillo: ' || v_antes5 || ' -> ' || v_desp5 ||
                         ' | Stock Tomacorriente: ' || v_antes6 || ' -> ' || v_desp6 ||
                         ' | Salidas en kardex: ' || v_kardex);
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PRUEBA 5 FALLO - ' || SQLERRM);
        ROLLBACK;
END;

-- Prueba 6: un INSERT directo en el detalle tambien descuenta el stock y escribe el kardex
DECLARE
    v_fac NUMBER; v_antes NUMBER; v_despues NUMBER; v_saldo NUMBER;
BEGIN
    SELECT ID_Factura INTO v_fac FROM FACTURAS_ENCABEZADO WHERE Estado = 'PENDIENTE';
    SELECT Stock_Actual INTO v_antes FROM PRODUCTOS WHERE ID_Producto = 10;
    INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (v_fac, 10, 3, 15.00);
    SELECT Stock_Actual INTO v_despues FROM PRODUCTOS WHERE ID_Producto = 10;
    SELECT Saldo_Resultante INTO v_saldo FROM MOVIMIENTOS_INVENTARIO
     WHERE ID_Factura = v_fac AND ID_Producto = 10 AND Tipo_Movimiento = 'SALIDA';
    DBMS_OUTPUT.PUT_LINE('PRUEBA 6 OK - Stock Brocha: ' || v_antes || ' -> ' || v_despues ||
                         ' | saldo registrado en kardex: ' || v_saldo);
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PRUEBA 6 FALLO - ' || SQLERRM);
        ROLLBACK;
END;

-- Prueba 7: modificar la cantidad de una linea ajusta el stock; eliminarla lo repone
DECLARE
    v_fac NUMBER; v_det NUMBER; v_inicial NUMBER; v_tras_update NUMBER; v_tras_delete NUMBER;
BEGIN
    SELECT ID_Factura INTO v_fac FROM FACTURAS_ENCABEZADO WHERE Estado = 'PENDIENTE';
    SELECT ID_Detalle INTO v_det FROM FACTURAS_DETALLE WHERE ID_Factura = v_fac AND ID_Producto = 5;
    SELECT Stock_Actual INTO v_inicial FROM PRODUCTOS WHERE ID_Producto = 5;
    UPDATE FACTURAS_DETALLE SET Cantidad = Cantidad + 5 WHERE ID_Detalle = v_det;
    SELECT Stock_Actual INTO v_tras_update FROM PRODUCTOS WHERE ID_Producto = 5;
    DELETE FROM FACTURAS_DETALLE WHERE ID_Detalle = v_det;
    SELECT Stock_Actual INTO v_tras_delete FROM PRODUCTOS WHERE ID_Producto = 5;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 7 OK - Stock Bombillo: inicial ' || v_inicial ||
                         ' | tras +5 unidades en la linea: ' || v_tras_update ||
                         ' | tras eliminar la linea (20+5 devueltas): ' || v_tras_delete);
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PRUEBA 7 FALLO - ' || SQLERRM);
        ROLLBACK;
END;

-- Prueba 8: anular una factura devuelve el stock y escribe las entradas en el kardex
DECLARE
    v_antes1 NUMBER; v_antes3 NUMBER; v_desp1 NUMBER; v_desp3 NUMBER; v_kardex NUMBER;
BEGIN
    SELECT Stock_Actual INTO v_antes1 FROM PRODUCTOS WHERE ID_Producto = 1;
    SELECT Stock_Actual INTO v_antes3 FROM PRODUCTOS WHERE ID_Producto = 3;
    UPDATE FACTURAS_ENCABEZADO SET Estado = 'ANULADO' WHERE ID_Factura = 1;
    SELECT Stock_Actual INTO v_desp1 FROM PRODUCTOS WHERE ID_Producto = 1;
    SELECT Stock_Actual INTO v_desp3 FROM PRODUCTOS WHERE ID_Producto = 3;
    SELECT COUNT(*) INTO v_kardex FROM MOVIMIENTOS_INVENTARIO
     WHERE ID_Factura = 1 AND Tipo_Movimiento = 'ENTRADA';
    DBMS_OUTPUT.PUT_LINE('PRUEBA 8 OK - Factura 1 anulada. Martillo: ' || v_antes1 || ' -> ' || v_desp1 ||
                         ' | Desarmador: ' || v_antes3 || ' -> ' || v_desp3 ||
                         ' | Entradas en kardex: ' || v_kardex);
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PRUEBA 8 FALLO - ' || SQLERRM);
        ROLLBACK;
END;

-- Prueba 9: una factura anulada no puede reactivarse
BEGIN
    UPDATE FACTURAS_ENCABEZADO SET Estado = 'ANULADO' WHERE ID_Factura = 1;
    UPDATE FACTURAS_ENCABEZADO SET Estado = 'PAGADO'  WHERE ID_Factura = 1;
    DBMS_OUTPUT.PUT_LINE('ERROR: se reactivo una factura anulada.');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('PRUEBA 9 OK - Reactivacion rechazada: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('PRUEBA 9 FALLO - error inesperado: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;

-- ---- TOTALES ----

-- Prueba 10: el trigger recalcula el total de la factura al insertar un detalle
DECLARE
    v_fac NUMBER; v_antes NUMBER; v_despues NUMBER;
BEGIN
    SELECT ID_Factura INTO v_fac FROM FACTURAS_ENCABEZADO WHERE Estado = 'PENDIENTE';
    SELECT Total_Factura INTO v_antes FROM FACTURAS_ENCABEZADO WHERE ID_Factura = v_fac;
    INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (v_fac, 10, 1, 15.00);
    SELECT Total_Factura INTO v_despues FROM FACTURAS_ENCABEZADO WHERE ID_Factura = v_fac;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 10 OK - Total antes: ' || v_antes || ' | despues del INSERT: ' || v_despues ||
                         ' (diferencia 16.80 = 15 + 12% IVA)');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PRUEBA 10 FALLO - ' || SQLERRM);
        ROLLBACK;
END;

-- Prueba 11: compra exitosa (aumenta stock, registra entrada) y trigger de total de compra
DECLARE
    v_oc NUMBER; v_tot NUMBER; v_antes NUMBER; v_despues NUMBER;
    v_ord NUMBER; v_tot_antes NUMBER; v_tot_desp NUMBER;
BEGIN
    SELECT Stock_Actual INTO v_antes FROM PRODUCTOS WHERE ID_Producto = 19;
    sp_registrar_compra(10, 1, t_lineas_compra(t_linea_compra(19, 5, 320.00)), SYSDATE, v_oc, v_tot);
    SELECT Stock_Actual INTO v_despues FROM PRODUCTOS WHERE ID_Producto = 19;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 11a OK - Orden ' || v_oc || ' total Q' || v_tot ||
                         ' | stock Taladro: ' || v_antes || ' -> ' || v_despues);
    SELECT ID_Orden_Compra, Total_Compra INTO v_ord, v_tot_antes FROM ORDENES_COMPRA WHERE Estado_Orden = 'PENDIENTE';
    INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (v_ord, 16, 3, 40.00);
    SELECT Total_Compra INTO v_tot_desp FROM ORDENES_COMPRA WHERE ID_Orden_Compra = v_ord;
    DBMS_OUTPUT.PUT_LINE('PRUEBA 11b OK - Total orden pendiente antes: ' || v_tot_antes ||
                         ' | despues del INSERT: ' || v_tot_desp || ' (diferencia 120 = 3 x 40)');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PRUEBA 11 FALLO - ' || SQLERRM);
        ROLLBACK;
END;


-- ============================================================================
-- 5.7 VERIFICACION DE VISTAS Y COHERENCIA DEL KARDEX
-- ============================================================================
SELECT * FROM VW_INVENTARIO_CRITICO ORDER BY Faltante_Para_Minimo DESC;
SELECT * FROM VW_HISTORIAL_CONSOLIDADO ORDER BY Tipo_Operacion, Entidad, Fecha;

-- Coherencia: el stock de cada producto debe coincidir con el ultimo saldo del kardex.
-- Resultado esperado: 0 filas (ningun producto descuadrado).
SELECT p.ID_Producto, p.Nombre_Producto, p.Stock_Actual,
       (SELECT m.Saldo_Resultante
          FROM MOVIMIENTOS_INVENTARIO m
         WHERE m.ID_Movimiento = (SELECT MAX(m2.ID_Movimiento)
                                    FROM MOVIMIENTOS_INVENTARIO m2
                                   WHERE m2.ID_Producto = p.ID_Producto)) AS Saldo_Kardex
  FROM PRODUCTOS p
 WHERE p.Stock_Actual <> (SELECT m.Saldo_Resultante
                            FROM MOVIMIENTOS_INVENTARIO m
                           WHERE m.ID_Movimiento = (SELECT MAX(m2.ID_Movimiento)
                                                      FROM MOVIMIENTOS_INVENTARIO m2
                                                     WHERE m2.ID_Producto = p.ID_Producto));
