-- ===============================================================================================================================
-- FUNIL VENDAS
-- ===============================================================================================================================

-- a)	Quantas oportunidades existem em cada etapa?
SELECT
	status,
	COUNT(*) AS quantidade
FROM oportunidades
GROUP BY status
ORDER BY CASE status
    WHEN 'Prospecção' THEN 1
    WHEN 'Qualificação' THEN 2
    WHEN 'Proposta' THEN 3
    WHEN 'Negociação' THEN 4
    WHEN 'Ganha' THEN 5
    WHEN 'Perdida' THEN 6
END;

-- b)	Qual é o valor financeiro acumulado em cada etapa?
SELECT
	status,
	ROUND(SUM(valor), 2) AS valor_total
FROM oportunidades
GROUP BY status
ORDER BY CASE status
    WHEN 'Prospecção' THEN 1
    WHEN 'Qualificação' THEN 2
    WHEN 'Proposta' THEN 3
    WHEN 'Negociação' THEN 4
    WHEN 'Ganha' THEN 5
    WHEN 'Perdida' THEN 6
END;

-- c)	Onde está a maior concentração ou gargalo do funil?
WITH contagem_etapas AS (
	SELECT
		status,
		COUNT(*) AS quantidade
	FROM oportunidades
	WHERE status NOT IN ('Ganha', 'Perdida')
	GROUP BY status
),
ranking AS (
	SELECT
		status,
		quantidade,
		DENSE_RANK() OVER (ORDER BY quantidade DESC) AS posicao
	FROM contagem_etapas
)
SELECT
	status,
	quantidade
FROM ranking
WHERE posicao = 1
ORDER BY status;

-- d)	Quais negócios têm alta probabilidade e nenhuma interação recente?
WITH referencia AS (
	SELECT DATE(
		MAX(COALESCE(data_ultima_interacao, data_abertura))
	) AS data_referencia
	FROM oportunidades
)
SELECT 
	c.nome AS cliente,
	v.nome AS vendedor,
	p.nome AS produto,
	o.tempo_contrato,
	o.valor,
	o.status,
	o.probabilidade,
	o.data_abertura,
	o.data_ultima_interacao,
	CAST(
		julianday(r.data_referencia) -
		julianday(COALESCE(o.data_ultima_interacao, o.data_abertura))
		AS INTEGER
	) AS dias_sem_interacao
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
CROSS JOIN referencia r
WHERE o.probabilidade >= 60
	AND julianday(r.data_referencia) -
		julianday(COALESCE(o.data_ultima_interacao, o.data_abertura)) > 30
	AND o.status NOT IN ('Ganha', 'Perdida')
ORDER BY o.probabilidade DESC;

-- e)	Qual é o pipeline ponderado pela probabilidade?
SELECT 
	ROUND(SUM(o.valor * o.probabilidade / 100.0), 2) AS pipeline_ponderado
FROM oportunidades o
WHERE o.status NOT IN ('Ganha', 'Perdida');
