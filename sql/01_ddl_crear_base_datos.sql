-- ============================================================================
-- 01_ddl_crear_base_datos.sql
-- Crea el esquema (usuario) PROYECTO_DB que contendra todas las tablas.
-- En Oracle una "base de datos" de aplicacion equivale a un esquema/usuario.
--
-- EJECUTAR COMO: SYSTEM (o SYS) conectado al PDB (XEPDB1 en Oracle 21c XE).
--   Si usa la raiz (CDB$ROOT) aparecera ORA-65096; conectese a XEPDB1.
-- SI YA TIENE EL USUARIO PROYECTO_DB (como en las Fases 1 y 2) puede omitir este script:
--   el script 02 elimina y recrea todos los objetos del esquema.
--
-- ANTES DE EJECUTAR: reemplace <SU_CONTRASENA> por una contrasena propia.
-- No suba la contrasena real al repositorio.
-- ============================================================================

-- Crea el usuario solo si no existe (no destruye un esquema existente)
DECLARE
    v_existe NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM dba_users WHERE username = 'PROYECTO_DB';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER PROYECTO_DB IDENTIFIED BY "<SU_CONTRASENA>" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
    END IF;
END;

-- Privilegios necesarios para los scripts 02 al 05
GRANT CREATE SESSION   TO PROYECTO_DB;
GRANT CREATE TABLE     TO PROYECTO_DB;
GRANT CREATE SEQUENCE  TO PROYECTO_DB;
GRANT CREATE VIEW      TO PROYECTO_DB;
GRANT CREATE PROCEDURE TO PROYECTO_DB;
GRANT CREATE TRIGGER   TO PROYECTO_DB;
GRANT CREATE TYPE      TO PROYECTO_DB;

-- Verificacion: debe mostrar una fila con el usuario
SELECT username, account_status, created FROM dba_users WHERE username = 'PROYECTO_DB';
