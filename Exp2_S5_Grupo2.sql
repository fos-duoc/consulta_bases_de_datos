-- ============================================================
-- PRY2205 - Consulta de Bases de Datos
-- Experiencia 2 - Semana 5
-- Ejercicio Practico: Subconsultas - Taller Mecanico
-- Grupo 2: Fuad Onate S.
-- Fecha: 13/04/2026
-- ============================================================
-- Esquema: cliente_mec, vehiculo_cliente, mecanico,
--          orden_trabajo, trabajo_realizado
-- ============================================================


-- =============================================================
-- CASO 1: Listado de clientes con ordenes costosas
-- Identificar los clientes cuyos vehiculos tienen ordenes de
-- trabajo con un costo total superior al promedio general
-- de costos por orden.
-- Incluye: subconsulta, JOINs, funciones de fila, agrupacion,
--          filtros y ordenamiento.
-- =============================================================

SELECT
    c.id_cliente                                              AS "ID Cliente",
    INITCAP(c.nombre || ' ' || c.apellidoPaterno
            || ' ' || NVL(c.apellidoMaterno, ''))             AS "Nombre Completo",
    UPPER(v.marca || ' ' || v.modelo)                         AS "Vehiculo",
    v.patente                                                 AS "Patente",
    ot.id_orden                                               AS "Nro Orden",
    UPPER(ot.estado)                                          AS "Estado",
    TO_CHAR(ot.fecha, 'DD/MM/YYYY')                           AS "Fecha Orden",
    TO_CHAR(SUM(tr.costo * tr.cantidad), '$999G999G999')      AS "Costo Total Orden"
FROM
    cliente_mec          c
    JOIN vehiculo_cliente v  ON c.id_cliente  = v.id_cliente
    JOIN orden_trabajo   ot ON v.id_vehiculo = ot.id_vehiculo
    JOIN trabajo_realizado tr ON ot.id_orden  = tr.id_orden
GROUP BY
    c.id_cliente,
    c.nombre,
    c.apellidoPaterno,
    c.apellidoMaterno,
    v.marca,
    v.modelo,
    v.patente,
    ot.id_orden,
    ot.estado,
    ot.fecha
HAVING
    SUM(tr.costo * tr.cantidad) > (
        -- Subconsulta: promedio general de costo total por orden
        SELECT ROUND(AVG(total_orden))
        FROM (
            SELECT SUM(costo * cantidad) AS total_orden
            FROM   trabajo_realizado
            GROUP BY id_orden
        )
    )
ORDER BY
    c.id_cliente ASC;


-- =============================================================
-- CASO 2: Mecanicos con ordenes activas y costo destacado
-- Listar mecanicos asignados a ordenes cuyo costo total es
-- igual o superior al maximo costo de ordenes cerradas.
-- Crear tabla MECANICOS_DESTACADOS con el resultado.
-- Incluye: CREATE TABLE AS, subconsulta, JOINs, funciones,
--          CASE, filtros y ordenamiento.
-- =============================================================

-- Eliminar tabla si existe de una ejecucion anterior
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE mecanicos_destacados CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE mecanicos_destacados AS
SELECT
    m.id_mecanico                                              AS "ID Mecanico",
    INITCAP(m.nombre || ' ' || m.apellidoPaterno)              AS "Nombre Mecanico",
    UPPER(m.especialidad)                                      AS "Especialidad",
    TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_contrato) / 12)      AS "Anios Experiencia",
    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_contrato) / 12) < 2
            THEN 'Junior'
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, m.fecha_contrato) / 12) BETWEEN 2 AND 3
            THEN 'Semi-Senior'
        ELSE 'Senior'
    END                                                         AS "Nivel",
    ot.id_orden                                                AS "Nro Orden",
    TO_CHAR(ot.fecha, 'DD/MM/YYYY')                            AS "Fecha Orden",
    UPPER(ot.estado)                                           AS "Estado",
    TO_CHAR(SUM(tr.costo * tr.cantidad), '$999G999G999')       AS "Costo Total"
FROM
    mecanico             m
    JOIN orden_trabajo    ot ON m.id_mecanico = ot.id_mecanico
    JOIN trabajo_realizado tr ON ot.id_orden  = tr.id_orden
WHERE
    ot.estado IN ('Abierta', 'En Proceso')
GROUP BY
    m.id_mecanico,
    m.nombre,
    m.apellidoPaterno,
    m.especialidad,
    m.fecha_contrato,
    ot.id_orden,
    ot.fecha,
    ot.estado
HAVING
    SUM(tr.costo * tr.cantidad) >= (
        -- Subconsulta: maximo costo total entre ordenes cerradas
        SELECT NVL(MAX(total_cerrada), 0)
        FROM (
            SELECT SUM(t2.costo * t2.cantidad) AS total_cerrada
            FROM   trabajo_realizado t2
                   JOIN orden_trabajo o2 ON t2.id_orden = o2.id_orden
            WHERE  o2.estado = 'Cerrada'
            GROUP BY t2.id_orden
        )
    )
ORDER BY
    m.id_mecanico ASC;

-- Verificacion de la tabla creada
SELECT * FROM mecanicos_destacados;


-- =============================================================
-- CASO 3 (Adicional): Vehiculos con ordenes sin mecanico
-- Listar vehiculos que tienen ordenes de trabajo SIN mecanico
-- asignado, usando EXISTS.
-- =============================================================

SELECT
    v.patente                                                  AS "Patente",
    UPPER(v.marca || ' ' || v.modelo)                          AS "Vehiculo",
    v.anio                                                     AS "Anio",
    INITCAP(c.nombre || ' ' || c.apellidoPaterno)              AS "Duenio"
FROM
    vehiculo_cliente v
    JOIN cliente_mec c ON v.id_cliente = c.id_cliente
WHERE
    EXISTS (
        -- Subconsulta: existe al menos una orden sin mecanico
        SELECT 1
        FROM   orden_trabajo ot
        WHERE  ot.id_vehiculo = v.id_vehiculo
        AND    ot.id_mecanico IS NULL
    )
ORDER BY
    v.patente ASC;


-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
