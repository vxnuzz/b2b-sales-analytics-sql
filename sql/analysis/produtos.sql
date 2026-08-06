-- ===============================================================================================================================
-- PRODUTOS
-- ===============================================================================================================================

-- a)	Quais produtos e categorias geram mais receita?
SELECT
	p.categoria,
	ROUND(
		SUM(o.valor)
		,2
	) AS receita
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
WHERE o.status = 'Ganha'
GROUP BY p.categoria 
ORDER BY receita DESC;

-- produtos
SELECT
	p.nome AS produto,
	ROUND(
		SUM(o.valor),
		2
	) AS receita
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
WHERE o.status = 'Ganha'
GROUP BY o.id_produto, p.nome
ORDER BY receita DESC;

-- b)	Quais categorias possuem maior taxa de conversão?
SELECT
	p.categoria,
	ROUND(
		SUM(
		CASE
			WHEN o.status = 'Ganha' THEN 1
			ELSE 0
		END
		)
	) AS ganhas,
	COUNT(*) AS encerradas,
	ROUND(
		100.0 * SUM(
			CASE
				WHEN o.status = 'Ganha' THEN 1
				ELSE 0
			END
		) / NULLIF(COUNT(*), 0),
		2
	) AS taxa_conversao
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
WHERE o.status IN ('Ganha', 'Perdida')
GROUP BY p.categoria 
ORDER BY taxa_conversao DESC;

-- c)	Quais apresentam maior ticket médio?
SELECT
	p.categoria,
	ROUND(
		AVG(o.valor)
		,2
	) AS ticket_medio
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
WHERE o.status = 'Ganha'
GROUP BY p.categoria 
ORDER BY ticket_medio DESC;

-- d)	Quais produtos têm ciclos de vendas mais longos?
SELECT
	p.nome AS produto,
	ROUND(
		AVG(
			julianday(o.data_fechamento) -
			julianday(o.data_abertura)
		),
		1
	) AS ciclo_vendas,
	COUNT(*) AS qtde_vendas
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
WHERE o.status = 'Ganha'
	AND o.data_abertura IS NOT NULL
	AND o.data_fechamento IS NOT NULL
GROUP BY o.id_produto, p.nome
ORDER BY ciclo_vendas DESC;

-- e)	Quais são mais procurados por segmento, porte e região?

-- segmento
SELECT
	c.segmento,
	p.categoria,
	COUNT(*) AS qtde_opts
FROM oportunidades o 
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente 
INNER JOIN produtos p 
	ON p.id_produto = o.id_produto
GROUP BY c.segmento,p.categoria
ORDER BY c.segmento,qtde_opts  DESC;

-- porte
SELECT
	c.porte,
	p.categoria,
	COUNT(*) AS qtde_opts
FROM oportunidades o 
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente 
INNER JOIN produtos p 
	ON p.id_produto = o.id_produto
GROUP BY c.porte,p.categoria
ORDER BY c.porte,qtde_opts  DESC;

-- região
SELECT
	c.regiao,
	p.categoria,
	COUNT(*) AS qtde_opts
FROM oportunidades o 
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente 
INNER JOIN produtos p 
	ON p.id_produto = o.id_produto
GROUP BY c.regiao,p.categoria
ORDER BY c.regiao,qtde_opts  DESC;

-- f)	Quais produtos são vendidos com maior frequência em contratos de 24 ou 36 meses?
SELECT
	p.nome AS produto,
	o.tempo_contrato,
	COUNT(*) AS qtde_opts
FROM oportunidades o 
INNER JOIN produtos p 
	ON p.id_produto = o.id_produto
WHERE o.status = 'Ganha'
GROUP BY 
	o.tempo_contrato,
	o.id_produto,
	p.nome
ORDER BY o.tempo_contrato, qtde_opts DESC;

-- g)	Quais produtos têm muito interesse, mas baixa conversão?
SELECT
	p.nome AS produtos,
	SUM(
	CASE
		WHEN o.status IN ('Ganha', 'Perdida') THEN 1
		ELSE 0
	END
	) AS encerradas,
	SUM(
		CASE
			WHEN o.status = 'Ganha' THEN 1
			ELSE 0
		END
	) AS ganhas,
	COUNT(*) AS qtde_opts,
	ROUND(
		100.0 * SUM(
			CASE
				WHEN o.status = 'Ganha' THEN 1
				ELSE 0
			END
		) / NULLIF(
			SUM(
				CASE
					WHEN o.status IN ('Ganha', 'Perdida') THEN 1
					ELSE 0
				END
			), 0
		), 2
	) AS taxa_conversao
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
GROUP BY 
	o.id_produto, 
	p.nome
HAVING SUM(
    CASE
        WHEN o.status IN ('Ganha', 'Perdida') THEN 1
        ELSE 0
    END
) > 0
ORDER BY qtde_opts DESC, taxa_conversao ASC;