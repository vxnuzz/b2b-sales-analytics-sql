-- ===============================================================================================================================
-- VENDEDORES E METAS
-- ===============================================================================================================================

-- a)	Quem vende mais em valor e quantidade?

SELECT
	v.nome AS vendedor,
	ROUND(SUM(o.valor), 2) AS receita,
	COUNT(*) AS qtde_vendas
FROM oportunidades o 
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE o.status = 'Ganha'
GROUP BY o.id_vendedor, v.nome
ORDER BY receita DESC, qtde_vendas DESC;

SELECT
	v.nome AS vendedor,
	ROUND(SUM(o.valor), 2) AS receita,
	COUNT(*) AS qtde_vendas
FROM oportunidades o 
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE o.status = 'Ganha'
GROUP BY o.id_vendedor, v.nome
ORDER BY qtde_vendas DESC, receita DESC;

-- b)	Qual vendedor possui a melhor taxa de conversão?
SELECT
	v.nome AS vendedor,
	SUM(CASE
		WHEN o.status = 'Ganha' THEN 1 
		ELSE 0 
	END) AS  ganhas,
	COUNT(*) AS encerradas,
	ROUND(
		100.0 * SUM(CASE
			WHEN o.status = 'Ganha' THEN 1 
			ELSE 0
		END) / NULLIF(COUNT(*), 0),
		2
	) AS taxa_conversao
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor 
WHERE o.status IN ('Ganha', 'Perdida')
GROUP BY o.id_vendedor, v.nome 
ORDER BY taxa_conversao DESC;

-- c)	Quem apresenta o maior ticket médio?
SELECT
	v.nome AS vendedor,
	ROUND(
		AVG(o.valor),
		2
	) AS ticket_medio
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE status = 'Ganha'
GROUP BY o.id_vendedor,v.nome
ORDER BY ticket_medio DESC;

-- d)	Quem tem o ciclo de vendas mais curto?
SELECT
	v.nome AS vendedor,
	ROUND(
		AVG(
			julianday(data_fechamento) - 
			julianday(data_abertura)
		),
		1
	) AS ciclo_vendas_medio
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE o.status = 'Ganha'
	AND o.data_abertura IS NOT NULL
    AND o.data_fechamento IS NOT NULL
GROUP BY o.id_vendedor, v.nome
ORDER BY ciclo_vendas_medio ASC;

-- e)	Quem perde mais oportunidades?
SELECT
	v.nome AS vendedor,
	COUNT(*) qtde_perdas
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE status = 'Perdida'
GROUP BY o.id_vendedor, v.nome
ORDER BY qtde_perdas DESC;

-- f)	Quais vendedores possuem oportunidades estagnadas?
WITH referencia AS (
	SELECT DATE(
		MAX(COALESCE(data_ultima_interacao, data_abertura))
	) AS data_referencia
	FROM oportunidades
)
SELECT
	v.nome AS vendedor,
	SUM(
		CASE
			WHEN COALESCE(
			    o.data_ultima_interacao,
			    o.data_abertura
			) < DATE(r.data_referencia, '-30 days')
			THEN 1
			ELSE 0
		END
	) AS opts_estagnadas
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
CROSS JOIN referencia r
WHERE o.status NOT IN ('Ganha', 'Perdida')
GROUP BY o.id_vendedor, v.nome
	HAVING opts_estagnadas > 0
ORDER BY opts_estagnadas DESC;

-- g)	Qual é o desempenho de cada vendedor em relação à sua meta mensal?
SELECT
	v.nome AS vendedor,
	ROUND(SUM(o.valor), 2) AS valor_contratado_mes,
	ROUND (
		100.0 * SUM(o.valor) / NULLIF(v.meta_mensal, 0) 
		, 2
	) AS desempenho_percentual,
	v.meta_mensal,
	CASE 
		WHEN SUM(o.valor) >= meta_mensal THEN 'Atingiu'
		ELSE 'Não atingiu'
	END AS situacao,
	strftime('%Y-%m', data_fechamento) AS mes
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor =  o.id_vendedor
WHERE o.status = 'Ganha'
GROUP BY 
	o.id_vendedor, 
	v.nome, 
	v.meta_mensal, 
	strftime('%Y-%m', o.data_fechamento)
ORDER BY mes;

-- h) Como o desempenho comercial varia entre as regiões dos clientes?
SELECT
    c.regiao,
    ROUND(SUM(
        CASE
            WHEN o.status = 'Ganha' THEN o.valor
            ELSE 0
        END
    ), 2) AS receita,
    SUM(
        CASE
            WHEN o.status = 'Ganha' THEN 1
            ELSE 0
        END
    ) AS qtde_vendas,
    COUNT(*) AS encerradas,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN o.status = 'Ganha' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS taxa_conversao,
    ROUND(
        AVG(
            CASE
                WHEN o.status = 'Ganha' THEN o.valor
                ELSE NULL
            END
        ),
        2
    ) AS ticket_medio
FROM oportunidades o
INNER JOIN vendedores v
    ON v.id_vendedor = o.id_vendedor
INNER JOIN clientes c
    ON c.id_cliente = o.id_cliente
WHERE o.status IN ('Ganha', 'Perdida')
GROUP BY c.regiao
ORDER BY receita DESC;

-- i)	Os melhores resultados vêm de quantidade de vendas, ticket ou conversão?
SELECT
	v.nome AS vendedor,
	ROUND(
		SUM(
			CASE
				WHEN o.status = 'Ganha' THEN o.valor
				ELSE 0
			END
		), 2
	) AS receita,
	SUM(
		CASE
				WHEN o.status = 'Ganha' THEN 1
				ELSE 0
			END
	) AS qtde_vendas,
	ROUND(
		AVG(
			CASE
				WHEN o.status = 'Ganha' THEN o.valor 
				ELSE NULL
			END
		), 2
	) AS ticket_medio,
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
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE o.status IN ('Ganha', 'Perdida')
GROUP BY o.id_vendedor, v.nome
ORDER BY receita DESC;
