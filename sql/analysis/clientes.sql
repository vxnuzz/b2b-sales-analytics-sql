-- ===============================================================================================================================
-- CLIENTES E MERCADO
-- ===============================================================================================================================

-- a)	Quais segmentos geram mais receita?
SELECT
	c.segmento,
	ROUND(
		SUM(o.valor), 2
	) AS receita 
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
WHERE o.status = 'Ganha'
GROUP BY c.segmento
ORDER BY receita DESC;

-- b)	Qual segmento apresenta a maior taxa de conversão?
SELECT
	c.segmento,
	ROUND(
		100.0 * SUM(
			CASE
				WHEN o.status = 'Ganha' THEN 1
				ELSE 0
			END
		) / NULLIF(COUNT(*), 0),
		2
	) AS conversao
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
WHERE o.status IN ('Ganha', 'Perdida')
GROUP BY c.segmento
ORDER BY conversao DESC;

-- c)	Clientes pequenos, médios ou grandes têm maior ticket?
SELECT
	c.porte,
	ROUND(
		AVG(o.valor
		), 2
	) AS ticket_medio 
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
WHERE o.status = 'Ganha'
GROUP BY c.porte
ORDER BY ticket_medio DESC;

-- d)	Qual porte possui o menor ciclo de vendas?
SELECT
	c.porte,
	ROUND(
		AVG(
			julianday(data_fechamento) -
			julianday(data_abertura)
		),
		1
	) AS ciclo_vendas
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
WHERE o.status = 'Ganha'
	AND o.data_abertura IS NOT NULL
	AND o.data_fechamento IS NOT NULL
GROUP BY c.porte
ORDER BY ciclo_vendas ASC;

-- e)	Quais regiões geram mais oportunidades, vendas e receita?
SELECT
	c.regiao,
	COUNT(*) AS qtde_opts,
	SUM(
		CASE
			WHEN o.status = 'Ganha' THEN 1
			ELSE 0
		END
	) AS qtde_ganhas,
	ROUND(
		SUM(
			CASE
				WHEN o.status = 'Ganha' THEN o.valor
				ELSE 0
			END
		),
		2
	) AS receita
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
GROUP BY c.regiao
ORDER BY qtde_opts DESC, qtde_ganhas DESC;

-- f)	Quais clientes compraram mais de uma vez?
SELECT 
	c.nome AS clientes,
	COUNT(*) AS qtde_opts
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
WHERE o.status = 'Ganha'
GROUP BY c.nome
	HAVING COUNT(*) > 1
ORDER BY qtde_opts DESC;

-- g)	Quais clientes possuem várias oportunidades abertas?
SELECT 
	c.nome AS clientes,
	COUNT(*) AS qtde_opts_abertas
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
WHERE o.status NOT IN ('Ganha', 'Perdida')
GROUP BY c.nome
	HAVING COUNT(*) > 1
ORDER BY qtde_opts_abertas DESC;
