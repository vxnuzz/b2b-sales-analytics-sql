PRAGMA foreign_keys = ON;

INSERT  INTO vendedores (
	nome,
	regiao,
	meta_mensal
)
VALUES
	('Ana Souza', 'Norte', 12500),
	('Carlos Lima', 'Nordeste', 20000),
	('Mariana Santos', 'Centro-Oeste', 5000),
	('João Oliveira', 'Sudeste', 32500),
	('Fernando Costa', 'Sul', 15000),
	('Alina Altiba', 'Norte', 17500),
	('Maria Eduarda', 'Nordeste', 30000),
	('Daniel Moisés', 'Centro-Oeste', 12500),
	('Elis Calcedo', 'Sudeste', 27500),
	('Luciano Zorte', 'Sul', 7500),
	('Paulo Wrobel', 'Norte', 12500),
	('Gabriel Sguario', 'Nordeste', 20000),
	('Jeniffer Toledo', 'Centro-Oeste', 12500),
	('Vinicius Ramos', 'Sudeste', 22500),
	('Alice Pereira', 'Sul', 12500);


INSERT INTO produtos (
	nome,
	categoria,
	preco
)
VALUES
	('Diagnóstico Comercial 360º','Consultoria', 8000),
	('Planejamento Estratégico Comercial','Estratégia', 18000),
	('Inteligência de Mercado','Estratégia', 15000),
	('Implementação de CRM','Tecnologia', 25000),
	('Migração e Limpeza de CRM','Tecnologia', 14000),
	('Automação de Prospecção','Automação', 18000),
	('Automação de Follow-up','Automação', 12000),
	('Estruturação de Inside Sales','Vendas', 30000),
	('Otimização do Funil de Vendas','Vendas', 20000),
	('Construção de Playbook','Vendas', 16000),
	('Programa de Customer Success', 'Relacionamento', 24000),
	('Programa de Redução de Churn', 'Relacionamento', 22000),
	('Dashboard Executivo de Vendas','Dados e BI', 16000),
	('Governança de Dados Comerciais', 'Dados e BI', 28000),
	('Previsão de Receita com IA','Inteligência Artificial', 35000),
	('Assistente Comercial com IA','Inteligência Artificial', 40000),
	('Qualificação de Leads com IA','Inteligência Artificial', 32000),
	('Treinamento de Vendas Consultivas','Capacitação', 12000),
	('Mentoria para Lideranças Comerciais','Capacitação', 15000),
	('Gestão Comercial Terceirizada','Outsourcing', 60000);
