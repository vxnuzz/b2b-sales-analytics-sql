import sqlite3
from pathlib import Path


def obter_conexao(caminho_banco: Path) -> sqlite3.Connection:
    conexao = sqlite3.connect(caminho_banco)
    conexao.row_factory = sqlite3.Row
    conexao.execute("PRAGMA foreign_keys = ON")
    return conexao


def executar_arquivo_sql(
    conexao: sqlite3.Connection,
    caminho_sql: Path,
) -> None:
    sql = caminho_sql.read_text(encoding="utf-8")
    conexao.executescript(sql)
