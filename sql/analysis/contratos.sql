-- ===============================================================================================================================
-- CONTRATOS
-- ===============================================================================================================================

-- a)	Contratos de 24 ou 36 meses convertem melhor?
SELECT
	o.tempo_contrato,
	SUM(
		CASE
			WHEN o.status = 'Ganha' THEN 1
			ELSE 0
		END
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
WHERE o.status IN ('Ganha', 'Perdida')
GROUP BY o.tempo_contrato 
ORDER BY taxa_conversao DESC;

-- b)	Qual duração produz o maior ticket?
SELECT
	o.tempo_contrato,
	ROUND(
		AVG(o.valor
		), 2
	) AS ticket_medio
FROM oportunidades o
WHERE o.status = 'Ganha'
GROUP BY o.tempo_contrato 
ORDER BY ticket_medio DESC;

-- c)	Que segmentos preferem cada duração?
SELECT 
	c.segmento,
	COUNT(*) AS qtde,
	o.tempo_contrato
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
GROUP BY c.segmento,o.tempo_contrato
ORDER BY c.segmento, qtde DESC;

-- d)	Quais produtos são mais associados a contratos longos?
SELECT 
	p.nome AS produto,
	COUNT(*) AS qtde,
	o.tempo_contrato
FROM oportunidades o
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
WHERE o.tempo_contrato = 36
GROUP BY 
	o.id_produto,
	p.nome,
	o.tempo_contrato
ORDER BY qtde DESC;

-- e)	Contratos de 36 meses demoram mais para fechar?
SELECT
	tempo_contrato,
	ROUND(
		AVG(
			julianday(data_fechamento) -
			julianday(data_abertura)
		),
		1
	) AS ciclo_vendas
FROM oportunidades
WHERE status = 'Ganha'
	AND data_abertura IS NOT NULL 
	AND data_fechamento IS NOT NULL
GROUP BY tempo_contrato
ORDER BY ciclo_vendas DESC;
