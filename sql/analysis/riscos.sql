-- ===============================================================================================================================
-- PERDAS E RISCOS
-- ===============================================================================================================================

-- a)	Quais vendedores, produtos ou segmentos apresentam mais perdas?

-- vendedores
SELECT
	v.nome AS vendedor,
	COUNT(*) AS qtde
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE o.status = 'Perdida'
GROUP BY o.id_vendedor, v.nome
ORDER BY qtde DESC;

-- produtos
SELECT 
	p.nome AS produto,
	COUNT(*) AS qtde
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
WHERE o.status = 'Perdida'
GROUP BY o.id_produto, p.nome
ORDER BY qtde DESC;

-- segmentos
SELECT 
	c.segmento,
	COUNT(*) AS qtde
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
WHERE o.status = 'Perdida'
GROUP BY c.segmento
ORDER BY qtde DESC;

-- b)	Quais oportunidades abertas estão sem interação há muitos dias?
WITH referencia AS (
	SELECT DATE(
		MAX(COALESCE(data_ultima_interacao, data_abertura))
	) AS data_referencia
	FROM oportunidades
)
SELECT
	o.id_oportunidade,
	c.nome AS cliente,
	v.nome AS vendedor,
	p.nome AS produto,
	ROUND(o.valor, 2) AS valor,
	o.status,
	o.probabilidade,
	o.data_abertura,
	o.data_ultima_interacao,
	CAST(
		julianday(r.data_referencia) -
		julianday(
			COALESCE(
				o.data_ultima_interacao,
				o.data_abertura
			)
		)
		AS INTEGER
	) AS qtde_dias_sem_interacao
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
CROSS JOIN referencia r
WHERE o.status NOT IN ('Ganha', 'Perdida')
	AND julianday(r.data_referencia) -
    	julianday(
        	COALESCE(
	        	o.data_ultima_interacao, 
	        	o.data_abertura
	        )
    	) > 30
ORDER BY qtde_dias_sem_interacao DESC;

-- c)	Quanto valor está em risco no pipeline?
WITH referencia AS (
	SELECT DATE(
		MAX(COALESCE(data_ultima_interacao, data_abertura))
	) AS data_referencia
	FROM oportunidades
)
SELECT
    COUNT(*) AS qtde_oportunidades_em_risco,
    ROUND(
        SUM(o.valor),
        2
    ) AS valor_total_em_risco,
    ROUND(
        SUM(o.valor * o.probabilidade / 100.0),
        2
    ) AS valor_ponderado_em_risco
FROM oportunidades AS o
CROSS JOIN referencia AS r
WHERE o.status NOT IN ('Ganha', 'Perdida')
  AND julianday(r.data_referencia) -
      julianday(
          COALESCE(
              o.data_ultima_interacao,
              o.data_abertura
          )
      ) > 30;

-- d)	Existem concentrações excessivas em determinados clientes ou produtos?

-- clientes
WITH valor_por_cliente AS (
    SELECT
        c.id_cliente,
        c.nome AS cliente,
        SUM(o.valor) AS valor_pipeline
    FROM oportunidades AS o
    INNER JOIN clientes AS c
        ON c.id_cliente = o.id_cliente
    WHERE o.status NOT IN ('Ganha', 'Perdida')
    GROUP BY c.id_cliente, c.nome
),
calculo AS (
    SELECT
        cliente,
        valor_pipeline,
        SUM(valor_pipeline) OVER () AS pipeline_total,
        SUM(valor_pipeline) OVER (
            ORDER BY valor_pipeline DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS valor_acumulado
    FROM valor_por_cliente
)
SELECT
    cliente,
    ROUND(valor_pipeline, 2) AS valor_pipeline,
    ROUND(
        100.0 * valor_pipeline /
        NULLIF(pipeline_total, 0),
        2
    ) AS participacao_percentual,
    ROUND(
        100.0 * valor_acumulado /
        NULLIF(pipeline_total, 0),
        2
    ) AS participacao_acumulada
FROM calculo
ORDER BY valor_pipeline DESC;

-- produto
WITH valor_por_produto AS (
    SELECT
        p.id_produto,
        p.nome AS produto,
        SUM(o.valor) AS valor_pipeline
    FROM oportunidades AS o
    INNER JOIN produtos AS p
        ON p.id_produto = o.id_produto
    WHERE o.status NOT IN ('Ganha', 'Perdida')
    GROUP BY p.id_produto, p.nome
),
calculo AS (
    SELECT
        produto,
        valor_pipeline,
        SUM(valor_pipeline) OVER () AS pipeline_total,
        SUM(valor_pipeline) OVER (
            ORDER BY valor_pipeline DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS valor_acumulado
    FROM valor_por_produto
)
SELECT
    produto,
    ROUND(valor_pipeline, 2) AS valor_pipeline,
    ROUND(
        100.0 * valor_pipeline /
        NULLIF(pipeline_total, 0),
        2
    ) AS participacao_percentual,
    ROUND(
        100.0 * valor_acumulado /
        NULLIF(pipeline_total, 0),
        2
    ) AS participacao_acumulada
FROM calculo
ORDER BY valor_pipeline DESC;
