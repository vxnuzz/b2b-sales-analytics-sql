from datetime import date
from pathlib import Path

DIRETORIO_PROJETO = Path(__file__).resolve().parents[1]

CAMINHO_BANCO = DIRETORIO_PROJETO / "data" / "b2b-sales.db"
CAMINHO_SCHEMA = DIRETORIO_PROJETO / "sql" / "setup" / "00_schemas.sql"
CAMINHO_SEED = DIRETORIO_PROJETO / "sql" / "setup" / "01_seed.sql"

# Manter uma data fixa garante resultados reproduzíveis.
DATA_REFERENCIA = date(2026, 8, 3)

QUANTIDADE_CLIENTES = 100
QUANTIDADE_OPORTUNIDADES = 1000

SEMENTE_CLIENTES = 42
SEMENTE_OPORTUNIDADES = 42
