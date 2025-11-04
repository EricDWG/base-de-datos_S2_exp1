--FACTURAS

SELECT

    LPAD(rut,10,'0') AS rut_cliente,
    nombre_cliente AS nombre,
    fecha_emision AS fecha,
    monto_neto AS monto,
    CASE 
        WHEN monto_neto BETWEEN 0 AND 50000 THEN 'Bajo'
        WHEN monto_neto BETWEEN 50001 AND 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS nivel_venta,
    CASE 
        WHEN tipo_pago = 1 THEN 'EFECTIVO'
        WHEN tipo_pago = 2 THEN 'TARJETA DEBITO'
        WHEN tipo_pago = 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END AS medio_pago
FROM factura
WHERE EXTRACT(YEAR FROM fecha_emision) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY fecha_emision DESC, monto_neto DESC;

--CLIENTES

SELECT 
    UPPER(nombre_cliente) AS nombre,
    telefono,
    NVL(email,'SIN CORREO') AS correo,
    TO_CHAR(fecha_registro,'DD/MM/YYYY') AS fecha_ingreso
FROM cliente
WHERE LENGTH(rut) = 10
ORDER BY nombre_cliente ASC;

--PRODUCTOS

DEFINE TC = 900
DEFINE UMB_B = 50
DEFINE UMB_A = 120

SELECT 
    id_producto,
    descripcion,
    NVL(valor_compra_usd,'Sin registro') AS valor_usd,
    CASE 
        WHEN valor_compra_usd IS NULL THEN 'Sin registro'
        ELSE valor_compra_usd * &TC
    END AS valor_clp,
    totalstock,
    CASE 
        WHEN totalstock IS NULL THEN 'Sin datos'
        WHEN totalstock < &UMB_B THEN 'ALERTA stock muy bajo'
        WHEN totalstock BETWEEN &UMB_B AND &UMB_A THEN 'Reabastecer pronto'
        ELSE 'OK'
    END AS estado_stock,
    CASE 
        WHEN totalstock > 80 THEN ROUND(valor_unitario * 0.9,0)
        ELSE valor_unitario
    END AS valor_con_desc
FROM producto
WHERE LOWER(descripcion) LIKE '%zapato%'
AND procedencia = 'i'
ORDER BY id_producto DESC;
