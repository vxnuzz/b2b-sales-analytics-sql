import random
import sqlite3
from datetime import date, timedelta


def gerar_status_e_probabilidade(
    gerador: random.Random,
) -> tuple[str, int]:
    status = gerador.choices(
        population=[
            "Prospecção",
            "Qualificação",
            "Proposta",
            "Negociação",
            "Ganha",
            "Perdida",
        ],
        weights=[20, 20, 15, 15, 20, 10],
        k=1,
    )[0]

    faixas = {
        "Prospecção": (5, 25),
        "Qualificação": (20, 45),
        "Proposta": (40, 65),
        "Negociação": (60, 85),
        "Ganha": (100, 100),
        "Perdida": (0, 0),
    }

    minimo, maximo = faixas[status]

    return status, gerador.randint(minimo, maximo)


def popular_oportunidades(
    conexao: sqlite3.Connection,
    quantidade: int,
    data_referencia: date,
    semente: int,
) -> int:
    gerador = random.Random(semente)

    clientes = conexao.execute(
        """
        SELECT id_cliente, regiao
        FROM clientes
        """
    ).fetchall()

    vendedores = conexao.execute(
        """
        SELECT id_vendedor, regiao
        FROM vendedores
        """
    ).fetchall()

    produtos = conexao.execute(
        """
        SELECT id_produto, preco
        FROM produtos
        """
    ).fetchall()

    if not clientes:
        raise ValueError("Nenhum cliente encontrado.")

    if not vendedores:
        raise ValueError("Nenhum vendedor encontrado.")

    if not produtos:
        raise ValueError("Nenhum produto encontrado.")

    vendedores_por_regiao = {}

    for id_vendedor, regiao in vendedores:
        vendedores_por_regiao.setdefault(
            regiao,
            [],
        ).append(id_vendedor)

    oportunidades = []

    for _ in range(quantidade):
        tempo_contrato = gerador.choice([24, 36])

        multiplicador_prazo = (
            1.0 if tempo_contrato == 24 else 1.3
        )

        id_cliente, regiao_cliente = gerador.choice(clientes)

        vendedores_compativeis = vendedores_por_regiao.get(
            regiao_cliente,
            [],
        )

        if not vendedores_compativeis:
            raise ValueError(
                "Não existe vendedor para a região "
                f"{regiao_cliente}."
            )

        id_vendedor = gerador.choice(vendedores_compativeis)
        id_produto, preco = gerador.choice(produtos)

        status, probabilidade = gerar_status_e_probabilidade(
            gerador
        )

        dias_desde_abertura = gerador.randint(1, 730)

        data_abertura = (
            data_referencia -
            timedelta(days=dias_desde_abertura)
        )

        if status in ("Ganha", "Perdida"):
            # O ciclo das oportunidades encerradas é limitado a 90 dias.
            dias_ate_interacao = gerador.randint(
                0,
                min(dias_desde_abertura, 90),
            )
            data_ultima_interacao = (
                data_abertura +
                timedelta(days=dias_ate_interacao)
            )
            data_fechamento = data_ultima_interacao.isoformat()
        else:
            # Aproximadamente 25% do pipeline aberto fica estagnado;
            # as demais oportunidades receberam interação recente.
            oportunidade_estagnada = gerador.random() < 0.25

            if oportunidade_estagnada and dias_desde_abertura > 30:
                dias_sem_interacao = gerador.randint(
                    31,
                    min(dias_desde_abertura, 120),
                )
            else:
                dias_sem_interacao = gerador.randint(
                    0,
                    min(dias_desde_abertura, 30),
                )

            data_ultima_interacao = max(
                data_referencia - timedelta(days=dias_sem_interacao),
                data_abertura,
            )
            data_fechamento = None

        valor = round(
            float(preco)
            * multiplicador_prazo
            * gerador.uniform(0.90, 1.20),
            2,
        )

        oportunidades.append(
            (
                id_cliente,
                id_vendedor,
                id_produto,
                tempo_contrato,
                valor,
                status,
                probabilidade,
                data_abertura.isoformat(),
                data_ultima_interacao.isoformat(),
                data_fechamento,
            )
        )

    conexao.executemany(
        """
        INSERT INTO oportunidades (
            id_cliente,
            id_vendedor,
            id_produto,
            tempo_contrato,
            valor,
            status,
            probabilidade,
            data_abertura,
            data_ultima_interacao,
            data_fechamento
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        oportunidades,
    )

    return len(oportunidades)
