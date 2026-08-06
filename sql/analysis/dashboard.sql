-- ===============================================================================================================================
-- PERGUNTAS PRIORITÁRIAS PARA UM DASHBOARD EXECUTIVO
-- ===============================================================================================================================

-- a)	Quanto foi vendido por mês?
SELECT
	strftime('%Y-%m', data_fechamento) AS mes,
	ROUND(SUM(valor), 2) AS receita_total
FROM oportunidades
WHERE status = 'Ganha'
GROUP BY strftime('%Y-%m', data_fechamento)
ORDER BY mes;

-- b)	Qual é a taxa de conversão das oportunidades encerradas?
SELECT
	ROUND(
		100.0 * SUM(CASE WHEN status = 'Ganha' THEN 1 ELSE 0 END)
		/ NULLIF(COUNT(*), 0),
		2
	) AS taxa_conversao_percentual
FROM oportunidades
WHERE status IN ('Ganha', 'Perdida');

-- c)	Qual é o valor total e ponderado do pipeline?
SELECT
	ROUND(SUM(valor), 2) AS pipeline_total,
	ROUND(SUM(valor * probabilidade / 100.0), 2) AS pipeline_ponderado
FROM oportunidades
WHERE status NOT IN ('Ganha', 'Perdida');

-- d)	Onde estão os gargalos do funil?
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

-- e)	Quais vendedores estão atingindo suas metas?
SELECT
	v.nome AS vendedor,
	v.regiao,
	ROUND(SUM(o.valor), 2) AS valor_contratado_mes,
	v.meta_mensal,
	CASE 
        WHEN SUM(o.valor) >= v.meta_mensal THEN 'Atingiu'
		ELSE 'Não atingiu'
	END AS situacao,
	strftime('%Y-%m', o.data_fechamento) AS mes
FROM oportunidades o
INNER JOIN vendedores v
	ON v.id_vendedor = o.id_vendedor
WHERE o.status = 'Ganha'
GROUP BY
	o.id_vendedor,
	v.nome,
	v.regiao,
	v.meta_mensal,
	strftime('%Y-%m', o.data_fechamento)
ORDER BY mes, v.nome;

-- f)	Quais oportunidades estão paradas ou em risco?
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
    o.status AS etapa,
    ROUND(o.valor, 2) AS valor,
    o.probabilidade,
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
    ) AS dias_parada
FROM oportunidades AS o
JOIN clientes AS c
    ON c.id_cliente = o.id_cliente
JOIN vendedores AS v
    ON v.id_vendedor = o.id_vendedor
JOIN produtos AS p
    ON p.id_produto = o.id_produto
CROSS JOIN referencia AS r
WHERE o.status NOT IN ('Ganha', 'Perdida')
  AND julianday(r.data_referencia) -
      julianday(
          COALESCE(
              o.data_ultima_interacao,
              o.data_abertura
          )
      ) > 30
ORDER BY dias_parada DESC;

-- g)	Qual é a previsão de receita dos próximos meses?
WITH referencia AS (
    SELECT DATE(
        MAX(COALESCE(data_ultima_interacao, data_abertura))
    ) AS data_referencia
    FROM oportunidades
),
tempo_medio AS (
    SELECT
        ROUND(
            AVG(
                julianday(data_fechamento) -
                julianday(data_abertura)
            ),
            1
        ) AS media_dias
    FROM oportunidades
    WHERE status = 'Ganha'
),
previsao AS (
    SELECT
        o.id_oportunidade,
        DATE(
            r.data_referencia,
            '+' || MAX(
                1,
                ROUND(tm.media_dias * (100 - o.probabilidade) / 100.0, 0)
            ) || ' days'
        ) AS data_estimada_fechamento,
        o.valor * o.probabilidade / 100.0 AS receita_ponderada,
        r.data_referencia
    FROM oportunidades AS o
    CROSS JOIN tempo_medio AS tm
    CROSS JOIN referencia AS r
    WHERE o.status NOT IN ('Ganha', 'Perdida')
)
SELECT
    strftime('%Y-%m', data_estimada_fechamento) AS mes,
    ROUND(SUM(receita_ponderada), 2) AS receita_prevista
FROM previsao
WHERE data_estimada_fechamento >= DATE(data_referencia, 'start of month')
  AND data_estimada_fechamento < DATE(data_referencia, 'start of month', '+4 months')
GROUP BY strftime('%Y-%m', data_estimada_fechamento)
ORDER BY mes;
