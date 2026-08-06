import random
import sqlite3
from datetime import date, timedelta

from faker import Faker

SEGMENTOS = [
    "Tecnologia",
    "Varejo",
    "Indústria",
    "Saúde",
    "Serviços",
]

PORTES = [
    "Pequeno",
    "Médio",
    "Grande",
]

REGIOES = [
    "Norte",
    "Nordeste",
    "Centro-Oeste",
    "Sudeste",
    "Sul",
]


def popular_clientes(
    conexao: sqlite3.Connection,
    quantidade: int,
    data_referencia: date,
    semente: int,
) -> int:
    gerador = random.Random(semente)
    fake = Faker("pt_BR")
    fake.seed_instance(semente)
    fake.unique.clear()

    clientes = []

    for _ in range(quantidade):
        dias_atras = gerador.randint(0, 730)

        clientes.append(
            (
                fake.unique.company(),
                gerador.choice(SEGMENTOS),
                gerador.choice(PORTES),
                gerador.choice(REGIOES),
                (data_referencia - timedelta(days=dias_atras)).isoformat(),
            )
        )

    conexao.executemany(
        """
        INSERT INTO clientes (
            nome,
            segmento,
            porte,
            regiao,
            data_cadastro
        )
        VALUES (?, ?, ?, ?, ?)
        """,
        clientes,
    )

    return len(clientes)
