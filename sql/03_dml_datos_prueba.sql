-- ============================================================================
-- 03_dml_datos_prueba.sql
-- Carga de datos de prueba (ferreteria). Ejecutar DESPUES de 02_ddl_crear_tablas.sql.
-- IMPORTANTE: este script se ejecuta ANTES de crear los triggers (05_extras_opcional.sql).
--   Los movimientos de kardex y las existencias finales se cargan de forma explicita;
--   si los triggers ya existieran, descontarian el stock por segunda vez.
-- Orden: catalogos -> personal -> productos -> kardex inicial -> compras/facturas.
-- Totales: 8 categorias, 15 proveedores, 16 clientes, 32 productos, 14 facturas,
--          32 lineas de detalle (minimos de la guia: 5 / 5 / 10 / 30 / 10 / 30).
-- ============================================================================
-- ============================================================================
-- SECCION 3: DML - CARGA MASIVA DE DATOS DE PRUEBA (INSERT)
-- ============================================================================

-- ---------- Catalogo: CATEGORIAS (8) ----------
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Herramientas Manuales', 'Martillos, desarmadores, llaves, taladros');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Material Electrico', 'Cables, bombillas, tomacorrientes');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Plomeria', 'Tuberia PVC, llaves y accesorios de agua');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Pinturas y Acabados', 'Pinturas, brochas y rodillos');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Fijaciones y Tornilleria', 'Tornillos, clavos, anclajes');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Seguridad Industrial', 'Cascos, guantes, lentes');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Jardineria', 'Mangueras, palas, herramientas de jardin');
INSERT INTO CATEGORIAS (Nombre_Categoria, Descripcion) VALUES ('Construccion', 'Cemento, varillas, block');

-- ---------- Catalogo: ROLES (5) ----------
INSERT INTO ROLES (Nombre_Rol, Descripcion) VALUES ('Administrador', 'Acceso total al sistema');
INSERT INTO ROLES (Nombre_Rol, Descripcion) VALUES ('Cajero', 'Cobro en cajas y facturacion');
INSERT INTO ROLES (Nombre_Rol, Descripcion) VALUES ('Bodeguero', 'Control de inventario y recepcion de compras');
INSERT INTO ROLES (Nombre_Rol, Descripcion) VALUES ('Vendedor', 'Atencion y asesoria al cliente');
INSERT INTO ROLES (Nombre_Rol, Descripcion) VALUES ('Gerente', 'Supervision de sucursal y reportes');

-- ---------- Catalogo: METODOS_PAGO (5) ----------
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Efectivo');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Tarjeta POS');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Transferencia');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Cheque');
INSERT INTO METODOS_PAGO (Nombre_Metodo) VALUES ('Deposito Bancario');

-- ---------- Catalogo: SUCURSALES (5) ----------
INSERT INTO SUCURSALES (Nombre_Sucursal, Direccion, Telefono) VALUES ('Sede Central', '6a Avenida 12-34, Zona 1, Guatemala', '2233-4455');
INSERT INTO SUCURSALES (Nombre_Sucursal, Direccion, Telefono) VALUES ('Sucursal Zona 10', '12 Calle 5-67, Zona 10, Guatemala', '2366-7788');
INSERT INTO SUCURSALES (Nombre_Sucursal, Direccion, Telefono) VALUES ('Sucursal Mixco', 'Calzada Roosevelt Km 15, Mixco', '2434-1122');
INSERT INTO SUCURSALES (Nombre_Sucursal, Direccion, Telefono) VALUES ('Sucursal Villa Nueva', 'Boulevard Principal 8-90, Villa Nueva', '6631-9900');
INSERT INTO SUCURSALES (Nombre_Sucursal, Direccion, Telefono) VALUES ('Sucursal Antigua', '4a Calle Poniente 10, Antigua Guatemala', '7832-5566');

-- ---------- Entidad principal: PROVEEDORES (15) ----------
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Distribuidora Electrica S.A.', '1000001-1', '2222-3333', 'ventas@distelectrica.com.gt', 'Carlos Ruiz');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Ferreteria Mayorista S.A.', '1000002-2', '2444-5555', 'compras@ferrmayorista.com.gt', 'Ana Lopez');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Aceros y Herramientas de Guatemala', '1000003-3', '2255-6677', 'info@acerosyherramientas.com.gt', 'Pedro Samayoa');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Pinturas Centroamericanas S.A.', '1000004-4', '2288-1100', 'pedidos@pinturascentro.com', 'Julia Arriaza');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Plomeria Industrial GT', '1000005-5', '2377-4400', 'ventas@plomeriagt.com', 'Mynor Cabrera');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Tornillos y Fijaciones del Norte', '1000006-6', '2411-9988', 'contacto@tornillosnorte.com.gt', 'Rosa Velasquez');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Seguridad Total S.A.', '1000007-7', '2299-3344', 'ventas@seguridadtotal.com.gt', 'Edgar Monzon');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Jardines y Mas S.A.', '1000008-8', '5544-2211', 'pedidos@jardinesymas.com', 'Claudia Herrera');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Materiales de Construccion Atlas', '1000009-9', '2466-7788', 'ventas@materialesatlas.com.gt', 'Byron Salguero');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Importadora Herramientas Pro', '1000010-0', '2333-5566', 'importaciones@herramientaspro.com', 'Gloria Paz');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Cables y Conductores S.A.', '1000011-1', '2244-8899', 'ventas@cablesyconductores.com.gt', 'Hugo Estrada');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Distribuidora La Economica', '1000012-2', '2477-1234', 'compras@laeconomica.com.gt', 'Silvia Coc');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Suministros Industriales Zona 12', '1000013-3', '2312-6655', 'ventas@suministrosz12.com', 'Manuel Aguilar');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Comercial Ferrex', '1000014-4', '2455-9090', 'info@ferrex.com.gt', 'Beatriz Orozco');
INSERT INTO PROVEEDORES (Nombre_Empresa, NIT, Telefono, Correo, Contacto_Principal) VALUES ('Maquinaria y Equipo Capital', '1000015-5', '2388-4747', 'ventas@maquinariacapital.com.gt', 'Rolando Sazo');

-- ---------- Entidad principal: CLIENTES (16) ----------
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('1123456-7', 'Juan Perez', 'Zona 1, Ciudad de Guatemala', '5555-1234', 'juan.perez@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('CF', 'Consumidor Final', 'Ciudad', '0000-0000', NULL);
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('2345678-9', 'Constructora Maya S.A.', 'Zona 4, Ciudad de Guatemala', '2321-4455', 'compras@constructoramaya.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('3456789-0', 'Maria Fernanda Lopez', 'Zona 7, Mixco', '5566-7788', 'mf.lopez@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('4567890-1', 'Carlos Mejia', 'Villa Nueva', '5599-1020', 'cmejia@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('5678901-2', 'Inmobiliaria Los Pinos', 'Zona 15, Ciudad de Guatemala', '2369-8800', 'admin@lospinos.com.gt');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('6789012-3', 'Ana Lucia Ramirez', 'Antigua Guatemala', '5533-4411', 'ana.ramirez@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('7890123-4', 'Taller Mecanico El Rayo', 'Zona 6, Ciudad de Guatemala', '2250-3030', 'elrayo@taller.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('8901234-5', 'Roberto Giron', 'Zona 18, Ciudad de Guatemala', '5522-9090', 'rgiron@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('9012345-6', 'Hotel Vista Hermosa S.A.', 'Panajachel, Solola', '7762-1100', 'mantenimiento@vistahermosa.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('1234567-8', 'Sofia Barrientos', 'Zona 11, Ciudad de Guatemala', '5544-6677', 'sofia.b@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('2234567-1', 'Ferreteria El Constructor', 'Chimaltenango', '7839-2200', 'pedidos@elconstructor.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('3234567-2', 'Luis Alberto Cano', 'Zona 3, Mixco', '5511-2233', 'lcano@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('4234567-3', 'Escuela Rural Los Cedros', 'San Lucas Sacatepequez', '7830-1818', 'direccion@loscedros.edu.gt');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('5234567-4', 'Patricia Ordonez', 'Zona 2, Ciudad de Guatemala', '5577-8899', 'pordonez@correo.com');
INSERT INTO CLIENTES (NIT, Nombre_Completo, Direccion, Telefono, Correo) VALUES ('6234567-5', 'Electricistas Unidos S.A.', 'Zona 5, Ciudad de Guatemala', '2335-7070', 'ventas@electricistasunidos.com');

-- ---------- Entidad principal: EMPLEADOS (15) ----------
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2001234560101', 'Mario Soto', 'Cajero General', 3600.00, DATE '2022-02-01', 1);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2002345670102', 'Lucia Mendez', 'Gerente de Tienda', 8500.00, DATE '2020-06-15', 1);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2003456780103', 'Pedro Alvarado', 'Cajero', 3400.00, DATE '2023-01-10', 2);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2004567890104', 'Sandra Castillo', 'Vendedora', 3200.00, DATE '2023-03-20', 2);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2005678900105', 'Jorge Barrios', 'Cajero', 3400.00, DATE '2021-08-05', 3);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2006789010106', 'Marta Ixcoy', 'Bodeguera', 3300.00, DATE '2021-11-12', 1);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2007890120107', 'Luis Garcia', 'Cajero', 3400.00, DATE '2022-07-18', 4);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2008901230108', 'Karla Morales', 'Vendedora', 3200.00, DATE '2024-02-26', 3);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2009012340109', 'Roberto Chavez', 'Bodeguero', 3300.00, DATE '2022-09-09', 2);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2010123450110', 'Andrea Lopez', 'Administradora', 7200.00, DATE '2019-04-01', 1);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2011234560111', 'Hector Ramirez', 'Vendedor', 3200.00, DATE '2023-10-02', 4);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2012345670112', 'Diana Perez', 'Cajera', 3400.00, DATE '2024-05-13', 5);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2013456780113', 'Oscar Tzoc', 'Bodeguero', 3300.00, DATE '2023-06-30', 5);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2014567890114', 'Veronica Solis', 'Vendedora', 3200.00, DATE '2024-08-19', 5);
INSERT INTO EMPLEADOS (DPI_Cedula, Nombre_Completo, Cargo, Salario, Fecha_Contratacion, ID_Sucursal) VALUES ('2015678900115', 'Fernando Cifuentes', 'Gerente de Tienda', 8200.00, DATE '2020-10-05', 3);

-- ---------- Entidad principal: USUARIOS (15) ----------
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('msoto',      RAWTOHEX(STANDARD_HASH('msoto2026',      'SHA256')), 1, 2);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('lmendez',    RAWTOHEX(STANDARD_HASH('lmendez2026',    'SHA256')), 2, 5);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('palvarado',  RAWTOHEX(STANDARD_HASH('palvarado2026',  'SHA256')), 3, 2);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('scastillo',  RAWTOHEX(STANDARD_HASH('scastillo2026',  'SHA256')), 4, 4);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('jbarrios',   RAWTOHEX(STANDARD_HASH('jbarrios2026',   'SHA256')), 5, 2);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('mixcoy',     RAWTOHEX(STANDARD_HASH('mixcoy2026',     'SHA256')), 6, 3);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('lgarcia',    RAWTOHEX(STANDARD_HASH('lgarcia2026',    'SHA256')), 7, 2);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('kmorales',   RAWTOHEX(STANDARD_HASH('kmorales2026',   'SHA256')), 8, 4);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('rchavez',    RAWTOHEX(STANDARD_HASH('rchavez2026',    'SHA256')), 9, 3);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('alopez',     RAWTOHEX(STANDARD_HASH('alopez2026',     'SHA256')), 10, 1);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('hramirez',   RAWTOHEX(STANDARD_HASH('hramirez2026',   'SHA256')), 11, 4);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('dperez',     RAWTOHEX(STANDARD_HASH('dperez2026',     'SHA256')), 12, 2);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('otzoc',      RAWTOHEX(STANDARD_HASH('otzoc2026',      'SHA256')), 13, 3);
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol, Estado) VALUES ('vsolis', RAWTOHEX(STANDARD_HASH('vsolis2026', 'SHA256')), 14, 4, 'INACTIVO');
INSERT INTO USUARIOS (Username, Password_Hash, ID_Empleado, ID_Rol) VALUES ('fcifuentes', RAWTOHEX(STANDARD_HASH('fcifuentes2026','SHA256')), 15, 5);

-- ---------- Entidad principal: PRODUCTOS (32 en total) ----------
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-001', 'Martillo de Acero 16oz',      25.00,  45.00,  60, 10, 1, 2);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-002', 'Rollo Cable Calibre 12',     150.00, 220.00,  10,  8, 2, 11);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-003', 'Desarmador Phillips #2',      8.00,  18.00,  80, 15, 1, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-004', 'Llave Ajustable 10 pulgadas', 35.00,  65.00,  40,  8, 1, 3);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-005', 'Bombillo LED 9W',             6.50,  15.00, 150, 30, 2, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-006', 'Tomacorriente Doble',         9.00,  20.00,  90, 20, 2, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-007', 'Tubo PVC 1/2 pulgada 6m',    18.00,  32.00,  70, 15, 3, 5);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-008', 'Llave de Chorro Bronce',     22.00,  42.00,  45, 10, 3, 5);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-009', 'Pintura Latex Blanca Galon',  95.00, 160.00,  12,  8, 4, 4);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-010', 'Brocha 3 pulgadas',          7.00,  15.00, 100, 20, 4, 4);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-011', 'Tornillo Drywall Caja 100u', 12.00,  25.00, 120, 25, 5, 6);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-012', 'Clavos 2 pulgadas Libra',     5.00,  10.00, 200, 40, 5, 6);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-013', 'Casco de Seguridad',        28.00,  55.00,  12, 10, 6, 7);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-014', 'Guantes de Carnaza',        14.00,  28.00,  60, 15, 6, 7);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-015', 'Manguera de Jardin 15m',    55.00,  95.00,   8,  6, 7, 8);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-016', 'Pala Cuadrada',            40.00,  75.00,   9,  6, 7, 8);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-017', 'Saco de Cemento 42.5kg',    78.00,  98.00, 100, 20, 8, 9);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-018', 'Varilla de Hierro 3/8',     38.00,  58.00, 150, 30, 8, 9);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-019', 'Taladro Percutor 1/2',     320.00, 495.00,   6,  4, 1, 10);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-020', 'Cinta Metrica 5m',         11.00,  24.00,  70, 15, 1, 12);

-- ---------- Productos adicionales (BARR-021 a BARR-032) para alcanzar 32 productos ----------
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-021', 'Sierra Manual 18 pulgadas', 30.00, 55.00, 40, 8, 1, 2);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-022', 'Interruptor Sencillo', 5.00, 12.00, 120, 25, 2, 1);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-023', 'Cable THHN #14 Rollo 100m', 180.00, 260.00, 7, 8, 2, 11);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-024', 'Codo PVC 1/2 pulgada', 1.50, 4.00, 300, 50, 3, 5);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-025', 'Rodillo para Pintura 9 pulgadas', 12.00, 25.00, 55, 12, 4, 4);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-026', 'Thinner Galon', 40.00, 70.00, 18, 10, 4, 4);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-027', 'Anclaje Expansivo 3/8 Caja', 20.00, 38.00, 45, 10, 5, 6);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-028', 'Lentes de Seguridad Transparentes', 9.00, 20.00, 3, 10, 6, 7);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-029', 'Tijera de Podar', 35.00, 68.00, 4, 5, 7, 8);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-030', 'Block de Concreto 15x20x40', 4.50, 7.50, 500, 100, 8, 9);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-031', 'Varilla de Hierro 1/2', 62.00, 90.00, 90, 25, 8, 9);
INSERT INTO PRODUCTOS (Codigo_Barras, Nombre_Producto, Precio_Compra, Precio_Venta, Stock_Actual, Stock_Minimo, ID_Categoria, ID_Proveedor) VALUES ('BARR-032', 'Esmeriladora Angular 4.5 pulgadas', 280.00, 420.00, 9, 4, 1, 15);

-- Movimiento inicial de kardex
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo)
SELECT ID_Producto, DATE '2026-08-31', 'ENTRADA', Stock_Actual, Stock_Actual, 'Inventario inicial'
FROM PRODUCTOS;

-- ---------- 3.2 Transacciones completas (12 compras recibidas, 14 facturas, 2 ordenes adicionales) ----------
-- C01
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0001', DATE '2026-09-02', 1190.00, 'RECIBIDA', 1, 1);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (1, 5, 100, 6.50);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (1, 6, 60, 9.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (5, DATE '2026-09-02', 'ENTRADA', 100, 250, 'Compra OC-2026-0001', 1);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (6, DATE '2026-09-02', 'ENTRADA', 60, 150, 'Compra OC-2026-0001', 1);

-- F01
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00001', DATE '2026-09-05', 144.00, 17.28, 161.28, 'PAGADO', 1, 1);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (1, 1, 2, 45.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (1, 3, 3, 18.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (161.28, DATE '2026-09-05', 'TRX-000001', 1, 1);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (1, DATE '2026-09-05', 'SALIDA', 2, 58, 'Venta FACT-2026-00001', 1);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (3, DATE '2026-09-05', 'SALIDA', 3, 77, 'Venta FACT-2026-00001', 1);

-- C02
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0002', DATE '2026-09-06', 1250.00, 'RECIBIDA', 2, 1);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (2, 1, 50, 25.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (1, DATE '2026-09-06', 'ENTRADA', 50, 108, 'Compra OC-2026-0002', 2);

-- F02
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00002', DATE '2026-09-08', 230.00, 27.60, 257.60, 'PAGADO', 2, 3);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (2, 5, 10, 15.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (2, 6, 4, 20.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (257.60, DATE '2026-09-08', 'TRX-000002', 2, 2);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (5, DATE '2026-09-08', 'SALIDA', 10, 240, 'Venta FACT-2026-00002', 2);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (6, DATE '2026-09-08', 'SALIDA', 4, 146, 'Venta FACT-2026-00002', 2);

-- C03
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0003', DATE '2026-09-09', 1020.00, 'RECIBIDA', 3, 2);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (3, 3, 40, 8.00);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (3, 4, 20, 35.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (3, DATE '2026-09-09', 'ENTRADA', 40, 117, 'Compra OC-2026-0003', 3);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (4, DATE '2026-09-09', 'ENTRADA', 20, 60, 'Compra OC-2026-0003', 3);

-- F03
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00003', DATE '2026-09-12', 730.00, 87.60, 817.60, 'PAGADO', 4, 1);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (3, 9, 4, 160.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (3, 10, 6, 15.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (817.60, DATE '2026-09-12', 'TRX-000003', 3, 3);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (9, DATE '2026-09-12', 'SALIDA', 4, 8, 'Venta FACT-2026-00003', 3);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (10, DATE '2026-09-12', 'SALIDA', 6, 94, 'Venta FACT-2026-00003', 3);

-- C04
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0004', DATE '2026-09-13', 350.00, 'RECIBIDA', 4, 1);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (4, 10, 50, 7.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (10, DATE '2026-09-13', 'ENTRADA', 50, 144, 'Compra OC-2026-0004', 4);

-- F04
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00004', DATE '2026-09-15', 2830.00, 339.60, 3169.60, 'PAGADO', 3, 5);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (4, 17, 20, 98.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (4, 18, 15, 58.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (3169.60, DATE '2026-09-15', 'TRX-000004', 4, 1);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (17, DATE '2026-09-15', 'SALIDA', 20, 80, 'Venta FACT-2026-00004', 4);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (18, DATE '2026-09-15', 'SALIDA', 15, 135, 'Venta FACT-2026-00004', 4);

-- C05
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0005', DATE '2026-09-17', 1160.00, 'RECIBIDA', 5, 3);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (5, 7, 40, 18.00);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (5, 8, 20, 22.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (7, DATE '2026-09-17', 'ENTRADA', 40, 110, 'Compra OC-2026-0005', 5);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (8, DATE '2026-09-17', 'ENTRADA', 20, 65, 'Compra OC-2026-0005', 5);

-- F05
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00005', DATE '2026-09-19', 1005.00, 120.60, 1125.60, 'PAGADO', 5, 7);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (5, 2, 4, 220.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (5, 11, 5, 25.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (1125.60, DATE '2026-09-19', 'TRX-000005', 5, 2);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (2, DATE '2026-09-19', 'SALIDA', 4, 6, 'Venta FACT-2026-00005', 5);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (11, DATE '2026-09-19', 'SALIDA', 5, 115, 'Venta FACT-2026-00005', 5);

-- C06
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0006', DATE '2026-09-20', 1220.00, 'RECIBIDA', 6, 1);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (6, 11, 60, 12.00);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (6, 12, 100, 5.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (11, DATE '2026-09-20', 'ENTRADA', 60, 175, 'Compra OC-2026-0006', 6);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (12, DATE '2026-09-20', 'ENTRADA', 100, 300, 'Compra OC-2026-0006', 6);

-- F06
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00006', DATE '2026-09-23', 1120.00, 134.40, 1254.40, 'PAGADO', 8, 1);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (6, 19, 2, 495.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (6, 4, 2, 65.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (1254.40, DATE '2026-09-23', 'TRX-000006', 6, 4);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (19, DATE '2026-09-23', 'SALIDA', 2, 4, 'Venta FACT-2026-00006', 6);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (4, DATE '2026-09-23', 'SALIDA', 2, 58, 'Venta FACT-2026-00006', 6);

-- C07
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0007', DATE '2026-09-24', 560.00, 'RECIBIDA', 7, 2);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (7, 14, 40, 14.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (14, DATE '2026-09-24', 'ENTRADA', 40, 100, 'Compra OC-2026-0007', 7);

-- F07
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00007', DATE '2026-09-27', 333.00, 39.96, 372.96, 'PAGADO', 6, 3);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (7, 13, 3, 55.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (7, 14, 6, 28.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (372.96, DATE '2026-09-27', 'TRX-000007', 7, 1);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (13, DATE '2026-09-27', 'SALIDA', 3, 9, 'Venta FACT-2026-00007', 7);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (14, DATE '2026-09-27', 'SALIDA', 6, 94, 'Venta FACT-2026-00007', 7);

-- C08
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0008', DATE '2026-09-28', 10840.00, 'RECIBIDA', 9, 1);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (8, 17, 100, 78.00);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (8, 18, 80, 38.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (17, DATE '2026-09-28', 'ENTRADA', 100, 180, 'Compra OC-2026-0008', 8);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (18, DATE '2026-09-28', 'ENTRADA', 80, 215, 'Compra OC-2026-0008', 8);

-- F08
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00008', DATE '2026-10-01', 488.00, 58.56, 546.56, 'PAGADO', 1, 12);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (8, 7, 10, 32.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (8, 8, 4, 42.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (546.56, DATE '2026-10-01', 'TRX-000008', 8, 2);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (7, DATE '2026-10-01', 'SALIDA', 10, 100, 'Venta FACT-2026-00008', 8);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (8, DATE '2026-10-01', 'SALIDA', 4, 61, 'Venta FACT-2026-00008', 8);

-- C09
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0009', DATE '2026-10-02', 900.00, 'RECIBIDA', 11, 4);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (9, 2, 6, 150.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (2, DATE '2026-10-02', 'ENTRADA', 6, 12, 'Compra OC-2026-0009', 9);

-- F09
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00009', DATE '2026-10-05', 585.00, 70.20, 655.20, 'PAGADO', 10, 5);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (9, 15, 3, 95.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (9, 16, 4, 75.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (655.20, DATE '2026-10-05', 'TRX-000009', 9, 3);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (15, DATE '2026-10-05', 'SALIDA', 3, 5, 'Venta FACT-2026-00009', 9);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (16, DATE '2026-10-05', 'SALIDA', 4, 5, 'Venta FACT-2026-00009', 9);

-- C10
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0010', DATE '2026-10-06', 440.00, 'RECIBIDA', 12, 5);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (10, 20, 40, 11.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (20, DATE '2026-10-06', 'ENTRADA', 40, 110, 'Compra OC-2026-0010', 10);

-- F10
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00010', DATE '2026-10-08', 621.00, 74.52, 695.52, 'PAGADO', 9, 1);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (10, 1, 5, 45.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (10, 12, 30, 10.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (10, 20, 4, 24.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (695.52, DATE '2026-10-08', 'TRX-000010', 10, 1);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (1, DATE '2026-10-08', 'SALIDA', 5, 103, 'Venta FACT-2026-00010', 10);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (12, DATE '2026-10-08', 'SALIDA', 30, 270, 'Venta FACT-2026-00010', 10);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (20, DATE '2026-10-08', 'SALIDA', 4, 106, 'Venta FACT-2026-00010', 10);

-- C11
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0011', DATE '2026-10-09', 780.00, 'RECIBIDA', 2, 3);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (11, 1, 30, 26.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (1, DATE '2026-10-09', 'ENTRADA', 30, 133, 'Compra OC-2026-0011', 11);

-- F11 (Factura PENDIENTE, sin pago)
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00011', DATE '2026-10-11', 620.00, 74.40, 694.40, 'PENDIENTE', 2, 7);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (11, 9, 2, 160.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (11, 5, 20, 15.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (9, DATE '2026-10-11', 'SALIDA', 2, 6, 'Venta FACT-2026-00011', 11);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (5, DATE '2026-10-11', 'SALIDA', 20, 220, 'Venta FACT-2026-00011', 11);

-- C12
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0012', DATE '2026-10-12', 750.00, 'RECIBIDA', 1, 1);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (12, 5, 60, 6.50);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (12, 6, 40, 9.00);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (5, DATE '2026-10-12', 'ENTRADA', 60, 280, 'Compra OC-2026-0012', 12);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Orden_Compra) VALUES (6, DATE '2026-10-12', 'ENTRADA', 40, 186, 'Compra OC-2026-0012', 12);

-- F12
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00012', DATE '2026-10-14', 5315.00, 637.80, 5952.80, 'PAGADO', 3, 12);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (12, 17, 30, 98.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (12, 18, 40, 58.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (12, 13, 1, 55.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (5952.80, DATE '2026-10-14', 'TRX-000012', 12, 5);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (17, DATE '2026-10-14', 'SALIDA', 30, 150, 'Venta FACT-2026-00012', 12);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (18, DATE '2026-10-14', 'SALIDA', 40, 175, 'Venta FACT-2026-00012', 12);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (13, DATE '2026-10-14', 'SALIDA', 1, 8, 'Venta FACT-2026-00012', 12);

-- C13 (Orden PENDIENTE)
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0013', DATE '2026-10-16', 1600.00, 'PENDIENTE', 10, 1);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (13, 19, 5, 320.00);

-- C14 (Orden ANULADA)
INSERT INTO ORDENES_COMPRA (Numero_Orden, Fecha_Orden, Total_Compra, Estado_Orden, ID_Proveedor, ID_Sucursal) VALUES ('OC-2026-0014', DATE '2026-10-10', 1090.00, 'ANULADA', 4, 2);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (14, 9, 10, 95.00);
INSERT INTO ORDENES_COMPRA_DETALLE (ID_Orden_Compra, ID_Producto, Cantidad, Precio_Compra_Unitario) VALUES (14, 10, 20, 7.00);

-- F13
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00013', DATE '2026-10-18', 980.00, 117.60, 1097.60, 'PAGADO', 7, 4);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (13, 21, 2, 55.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (13, 22, 10, 12.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (13, 30, 100, 7.50);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (1097.60, DATE '2026-10-18', 'TRX-000013', 13, 2);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (21, DATE '2026-10-18', 'SALIDA', 2, 38, 'Venta FACT-2026-00013', 13);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (22, DATE '2026-10-18', 'SALIDA', 10, 110, 'Venta FACT-2026-00013', 13);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (30, DATE '2026-10-18', 'SALIDA', 100, 400, 'Venta FACT-2026-00013', 13);

-- F14
INSERT INTO FACTURAS_ENCABEZADO (Numero_Factura, Fecha_Emision, Subtotal_Factura, Impuesto_IVA, Total_Factura, Estado, ID_Cliente, ID_Empleado) VALUES ('FACT-2026-00014', DATE '2026-10-20', 1720.00, 206.40, 1926.40, 'PAGADO', 16, 8);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (14, 23, 3, 260.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (14, 28, 2, 20.00);
INSERT INTO FACTURAS_DETALLE (ID_Factura, ID_Producto, Cantidad, Precio_Unitario) VALUES (14, 31, 10, 90.00);
INSERT INTO PAGOS_FACTURA (Monto_Pagado, Fecha_Pago, Numero_Transaccion, ID_Factura, ID_Metodo_Pago) VALUES (1926.40, DATE '2026-10-20', 'TRX-000014', 14, 3);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (23, DATE '2026-10-20', 'SALIDA', 3, 4, 'Venta FACT-2026-00014', 14);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (28, DATE '2026-10-20', 'SALIDA', 2, 1, 'Venta FACT-2026-00014', 14);
INSERT INTO MOVIMIENTOS_INVENTARIO (ID_Producto, Fecha_Movimiento, Tipo_Movimiento, Cantidad, Saldo_Resultante, Motivo, ID_Factura) VALUES (31, DATE '2026-10-20', 'SALIDA', 10, 80, 'Venta FACT-2026-00014', 14);

-- Ajuste de existencias finales en STOCK_ACTUAL
UPDATE PRODUCTOS SET Stock_Actual = 133 WHERE ID_Producto = 1;
UPDATE PRODUCTOS SET Stock_Actual = 12 WHERE ID_Producto = 2;
UPDATE PRODUCTOS SET Stock_Actual = 117 WHERE ID_Producto = 3;
UPDATE PRODUCTOS SET Stock_Actual = 58 WHERE ID_Producto = 4;
UPDATE PRODUCTOS SET Stock_Actual = 280 WHERE ID_Producto = 5;
UPDATE PRODUCTOS SET Stock_Actual = 186 WHERE ID_Producto = 6;
UPDATE PRODUCTOS SET Stock_Actual = 100 WHERE ID_Producto = 7;
UPDATE PRODUCTOS SET Stock_Actual = 61 WHERE ID_Producto = 8;
UPDATE PRODUCTOS SET Stock_Actual = 6 WHERE ID_Producto = 9;
UPDATE PRODUCTOS SET Stock_Actual = 144 WHERE ID_Producto = 10;
UPDATE PRODUCTOS SET Stock_Actual = 175 WHERE ID_Producto = 11;
UPDATE PRODUCTOS SET Stock_Actual = 270 WHERE ID_Producto = 12;
UPDATE PRODUCTOS SET Stock_Actual = 8 WHERE ID_Producto = 13;
UPDATE PRODUCTOS SET Stock_Actual = 94 WHERE ID_Producto = 14;
UPDATE PRODUCTOS SET Stock_Actual = 5 WHERE ID_Producto = 15;
UPDATE PRODUCTOS SET Stock_Actual = 5 WHERE ID_Producto = 16;
UPDATE PRODUCTOS SET Stock_Actual = 150 WHERE ID_Producto = 17;
UPDATE PRODUCTOS SET Stock_Actual = 175 WHERE ID_Producto = 18;
UPDATE PRODUCTOS SET Stock_Actual = 4 WHERE ID_Producto = 19;
UPDATE PRODUCTOS SET Stock_Actual = 106 WHERE ID_Producto = 20;
UPDATE PRODUCTOS SET Stock_Actual = 38 WHERE ID_Producto = 21;
UPDATE PRODUCTOS SET Stock_Actual = 110 WHERE ID_Producto = 22;
UPDATE PRODUCTOS SET Stock_Actual = 4 WHERE ID_Producto = 23;
UPDATE PRODUCTOS SET Stock_Actual = 1 WHERE ID_Producto = 28;
UPDATE PRODUCTOS SET Stock_Actual = 400 WHERE ID_Producto = 30;
UPDATE PRODUCTOS SET Stock_Actual = 80 WHERE ID_Producto = 31;

COMMIT;
