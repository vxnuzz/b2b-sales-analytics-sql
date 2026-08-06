import argparse
from pathlib import Path

from config import (
    CAMINHO_BANCO,
    CAMINHO_SEED,
    CAMINHO_SCHEMA,
    DATA_REFERENCIA,
    QUANTIDADE_CLIENTES,
    QUANTIDADE_OPORTUNIDADES,
    SEMENTE_CLIENTES,
    SEMENTE_OPORTUNIDADES,
)
from database import executar_arquivo_sql, obter_conexao
from generators.clientes import popular_clientes
from generators.oportunidades import popular_oportunidades

def construir_banco(forcar: bool = False) -> None:
    if CAMINHO_BANCO.exists() and not forcar:
        raise FileExistsError(
            "O banco já existe. Use --force para reconstruí-lo"
        )

    CAMINHO_BANCO.parent.mkdir(parents=True, exist_ok=True)

    # O arquivo publicado só é substituído após a construção terminar.
    banco_temporario = Path(f"{CAMINHO_BANCO}.tmp")

    if banco_temporario.exists():
        banco_temporario.unlink()

    conexao = obter_conexao(banco_temporario)

    try:
        executar_arquivo_sql(conexao, CAMINHO_SCHEMA)
        executar_arquivo_sql(conexao, CAMINHO_SEED)

        clientes = popular_clientes(
            conexao,
            QUANTIDADE_CLIENTES,
            DATA_REFERENCIA,
            SEMENTE_CLIENTES,
        )

        oportunidades = popular_oportunidades(
            conexao,
            QUANTIDADE_OPORTUNIDADES,
            DATA_REFERENCIA,
            SEMENTE_OPORTUNIDADES,
        )

        conexao.commit()

    except Exception:
        conexao.rollback()
        raise

    finally:
        conexao.close()

    banco_temporario.replace(CAMINHO_BANCO)

    print(f"Banco criado em: {CAMINHO_BANCO}")
    print(f"Clientes inseridos: {clientes}")
    print(f"Oportunidades inseridas: {oportunidades}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--force",
        action="store_true",
        help="Substitui o banco existente.",
    )
    argumentos = parser.parse_args()

    construir_banco(forcar=argumentos.force)
