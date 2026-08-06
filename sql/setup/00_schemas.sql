PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS clientes (
	id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
	nome TEXT UNIQUE NOT NULL,
	segmento TEXT NOT NULL
		CHECK (
			segmento IN (
				'Tecnologia',
				'Varejo',
				'Indústria',
				'Saúde',
				'Serviços'
			)
		),
	porte TEXT NOT NULL
		CHECK (
			porte IN (
				'Pequeno',
				'Médio',
				'Grande'
			)
		),
	regiao TEXT NOT NULL
		CHECK (
			regiao IN (
				'Norte',
				'Nordeste',
				'Centro-Oeste',
				'Sudeste',
				'Sul'
			)
		),
	data_cadastro DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS vendedores (
	id_vendedor INTEGER PRIMARY KEY AUTOINCREMENT,
	nome TEXT UNIQUE NOT NULL,
	regiao TEXT NOT NULL
		CHECK (
			regiao IN (
				'Norte',
				'Nordeste',
				'Centro-Oeste',
				'Sudeste',
				'Sul'
			)
		),
	meta_mensal NUMERIC NOT NULL 
		CHECK (meta_mensal >= 0)
);

CREATE TABLE IF NOT EXISTS produtos (
    id_produto INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT UNIQUE NOT NULL,
    categoria TEXT NOT NULL
        CHECK (
            categoria IN (
                'Consultoria',
                'Estratégia',
                'Tecnologia',
                'Automação',
                'Vendas',
                'Relacionamento',
                'Dados e BI',
                'Inteligência Artificial',
                'Capacitação',
                'Outsourcing'
            )
        ),
    preco NUMERIC NOT NULL
        CHECK (preco >= 0)
);

CREATE TABLE IF NOT EXISTS oportunidades (
	id_oportunidade INTEGER PRIMARY KEY AUTOINCREMENT,
	id_cliente INTEGER NOT NULL,
	id_vendedor INTEGER NOT NULL,
	id_produto INTEGER NOT NULL,
	tempo_contrato INTEGER NOT NULL
		CHECK (
			tempo_contrato IN (24,36)),
	valor NUMERIC NOT NULL
		CHECK (valor >= 0),
	status TEXT NOT NULL
		CHECK (
			status IN (
				'Prospecção',
				'Qualificação',
				'Proposta',
				'Negociação',
				'Ganha',
				'Perdida'
			)	
		),
	probabilidade INTEGER NOT NULL
		CHECK (probabilidade BETWEEN 0 AND 100),
	data_abertura DATE NOT NULL,
	data_ultima_interacao DATE NOT NULL,
	data_fechamento DATE,
	
	FOREIGN KEY (id_cliente)
		REFERENCES clientes(id_cliente),
	
	FOREIGN KEY(id_vendedor)
		REFERENCES vendedores(id_vendedor),
		
	FOREIGN KEY(id_produto)
		REFERENCES produtos(id_produto)
);

-- Índices das colunas mais usadas em relacionamentos e filtros analíticos.
CREATE INDEX IF NOT EXISTS idx_oportunidades_cliente
	ON oportunidades(id_cliente);

CREATE INDEX IF NOT EXISTS idx_oportunidades_vendedor
	ON oportunidades(id_vendedor);

CREATE INDEX IF NOT EXISTS idx_oportunidades_produto
	ON oportunidades(id_produto);

CREATE INDEX IF NOT EXISTS idx_oportunidades_status
	ON oportunidades(status);

CREATE INDEX IF NOT EXISTS idx_oportunidades_fechamento
	ON oportunidades(data_fechamento);

CREATE INDEX IF NOT EXISTS idx_oportunidades_interacao
	ON oportunidades(data_ultima_interacao);
