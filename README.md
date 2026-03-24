# consulta_bases_de_datos
Consulta Bases de Datos - Duoc Online 2026

<div align="center">

![Oracle](https://img.shields.io/badge/Oracle-F80000?style=flat-square&logo=oracle&logoColor=white)
![Semana](https://img.shields.io/badge/Semana-02-blue?style=flat-square)

# `Funciones SQL Aplicadas`

</div>

---

### Funciones Utilizadas

```sql
-- CARACTERES
UPPER('carlos')              -- CARLOS
LOWER('MUNOZ')               -- munoz
INITCAP('soto')              -- Soto
LENGTH('CARLOS Soto munoz')  -- 18
SUBSTR('Carlos', 1, 1)       -- C
NVL(apellido_materno, '')    -- Valor por defecto si NULL

-- NUMERICAS
TRUNC(128 / 60)              -- 2 (parte entera)
MOD(128, 60)                 -- 8 (resto)
LPAD(TO_CHAR(8), 2, '0')    -- 08 (relleno izquierdo)

-- FECHA
TO_CHAR(fecha, 'DD-MM-YYYY HH24:MI')                  -- 08-09-2025 15:00
TO_CHAR(fecha, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')     -- LUNES
INITCAP(TRIM(...))                                     -- Lunes
TRUNC(CAST(fecha AS DATE))                             -- Solo fecha, sin hora

-- CONVERSION
TO_CHAR(duracion_min)                  -- Numero a texto
TO_NUMBER(TO_CHAR(fecha, 'HH24'))     -- Hora como numero
TO_DATE('08-09-2025', 'DD-MM-YYYY')   -- Texto a fecha

-- EXPRESION CONDICIONAL
CASE
    WHEN hora BETWEEN 0  AND 15 THEN 'MATINE'
    WHEN hora BETWEEN 16 AND 20 THEN 'TARDE'
    WHEN hora BETWEEN 21 AND 23 THEN 'NOCHE'
END
```

---

<div align="center">
<sub>SQL Consultas - Experiencia 1</sub>
</div>
