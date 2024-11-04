"""Módulo para inserir dados no banco de dados."""

import os
from functools import wraps

import psycopg2
from dotenv import load_dotenv
from sqlalchemy import create_engine


def acessar_dotenv(func):
    """Load arquivo dot env."""

    @wraps(func)
    def wrapper(*args, **kwargs):
        load_dotenv()
        return func(*args, **kwargs)

    return wrapper


@acessar_dotenv
def conectar_db():
    """
    Conecta ao banco de dados PostgreSQL.
    """
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            database=os.getenv('DATABASE'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            port=os.getenv('DB_PORT'),
        )

        print('Conexão com o PostgreSQL bem sucedida!')

        return conn

    except Exception as error:
        print(f'Erro ao conectar ao PostgresSQL: {error}')


@acessar_dotenv
def inserir_dados_no_postgres(conn, data, nome_tabela):
    """
    Insere os dados do arquivo CSV após tratamento
    na tabela do PostgreSQL.

    conn.close(): Fecha a conexão.
    """
    try:
        engine = create_engine(
            f'postgresql://{os.getenv("DB_USER")}:{os.getenv("DB_PASSWORD")}@{os.getenv("DB_HOST")}/{os.getenv("DATABASE")}'
        )
        data.to_sql(nome_tabela, engine, if_exists='replace', index=False)
        print('Dados inseridos na tabela com sucesso!')

    except Exception as error:

        print(f'Erro ao inserir dados no PostgresSQL: {error}')
