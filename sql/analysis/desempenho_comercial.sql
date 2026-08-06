-- ===============================================================================================================================
-- DESEMPENHO COMERCIAL
-- ===============================================================================================================================

-- a)	Quanto foi vendido por trimestre e ano?

-- trimestre
SELECT
	ROUND(SUM(valor), 2) AS receita_total,
	strftime('%Y', data_fechamento) || '-T' ||
	(
	    CAST(
	        (CAST(strftime('%m', data_fechamento) AS INTEGER) - 1) / 3
	        AS INTEGER
	    ) + 1
	) AS trimestre
FROM oportunidades
WHERE status = 'Ganha'
GROUP BY strftime('%Y', data_fechamento) || '-T' ||
	(
	    CAST(
	        (CAST(strftime('%m', data_fechamento) AS INTEGER) - 1) / 3
	        AS INTEGER
	    ) + 1
	)
ORDER BY trimestre;

-- ano
SELECT
	ROUND(SUM(valor), 2) AS receita_total,
	strftime('%Y', data_fechamento) AS ano
FROM oportunidades
WHERE status = 'Ganha'
GROUP BY strftime('%Y', data_fechamento)
ORDER BY ano;

-- b)	A receita está crescendo ou diminuindo?
WITH receita_por_mes AS (
	SELECT
		ROUND(SUM(valor), 2) AS receita_mensal,
		strftime('%Y-%m', data_fechamento) AS mes
	FROM oportunidades
	WHERE status = 'Ganha'
	GROUP BY strftime('%Y-%m', data_fechamento)
	ORDER BY mes
),
comparacao AS (
	SELECT
		mes,
		receita_mensal,
		LAG(receita_mensal) OVER (ORDER BY mes) AS receita_mes_anterior
	FROM receita_por_mes
)
SELECT
	mes,
	receita_mensal,
	receita_mes_anterior,
	CASE 
		WHEN receita_mes_anterior IS NULL THEN 'Sem comparação'
		WHEN receita_mensal > receita_mes_anterior THEN 'Aumentou'
		WHEN receita_mensal < receita_mes_anterior THEN 'Diminuiu'
		ELSE 'Permaneceu igual'
	END AS tendencia
FROM comparacao
ORDER BY mes;

-- c)	Qual é o ticket médio das vendas ganhas?
SELECT 
	ROUND(AVG(valor), 2) AS ticket_medio
FROM oportunidades
WHERE status = 'Ganha';
	
-- d)	Quanto tempo uma oportunidade leva para ser fechada?
SELECT 
	ROUND(
		AVG(
			julianday(data_fechamento) -
			julianday(data_abertura)
		),
		1
	) AS media_dias
FROM oportunidades
WHERE status = 'Ganha';

-- e)	Em quais meses ocorrem mais ganhos e perdas?

-- rank mes com mais ganhas
SELECT
	strftime('%Y-%m', data_fechamento) AS mes,
	status,
	COUNT(*) AS quantidade
FROM oportunidades
WHERE status = 'Ganha'
GROUP BY strftime('%Y-%m', data_fechamento)
ORDER BY quantidade DESC;

-- rank mes com mais perdidas
SELECT
	strftime('%Y-%m', data_fechamento) AS mes,
	status,
	COUNT(*) AS quantidade
FROM oportunidades
WHERE status = 'Perdida'
GROUP BY strftime('%Y-%m', data_fechamento)
ORDER BY quantidade DESC;

-- f)	O ciclo de vendas está aumentando?
WITH media_vendas_mes AS (
	SELECT
		strftime('%Y-%m', data_fechamento) AS mes,
		ROUND(
			AVG(
				julianday(data_fechamento) -
				julianday(data_abertura)
			),
			1
		) AS media_dias
	FROM oportunidades
	WHERE status = 'Ganha'
	GROUP BY strftime('%Y-%m', data_fechamento)
),
comparacao AS (
	SELECT
		mes,
		media_dias,
		LAG(media_dias) OVER (ORDER BY mes) AS media_anterior
	FROM media_vendas_mes
)
SELECT 
	mes,
	media_dias,
	media_anterior,
	CASE
		WHEN media_anterior IS NULL THEN 'Início da operação — sem comparação'
		WHEN media_dias > media_anterior THEN 'Aumentou'
		WHEN media_dias < media_anterior THEN 'Diminuiu'
		ELSE 'Permaneceu igual'
	END AS situacao_ciclo
FROM comparacao
ORDER BY mes;

-- g)	Quais oportunidades representam a maior parte da receita?
SELECT
	c.nome AS cliente,
	v.nome AS vendedor,
	p.nome AS produto,
	o.tempo_contrato,
	o.valor,
	ROUND(SUM(o.valor) OVER (
		ORDER BY o.valor DESC, o.id_oportunidade
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	), 2) AS valor_acumulado,
	ROUND(SUM(o.valor) OVER (), 2) AS receita_total,
	ROUND(100.0 * o.valor
		/ NULLIF(SUM(o.valor) OVER (), 0), 2) AS participacao_percentual,
	ROUND(100.0 * SUM(o.valor) OVER (
		ORDER BY o.valor DESC, o.id_oportunidade
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / NULLIF(SUM(o.valor) OVER (), 0), 2) AS participacao_acumulada_percentual,
	o.data_abertura,
	o.data_fechamento
FROM oportunidades o
INNER JOIN clientes c
	ON c.id_cliente = o.id_cliente
INNER JOIN produtos p
	ON p.id_produto = o.id_produto
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE status = 'Ganha'
ORDER BY o.valor DESC;
