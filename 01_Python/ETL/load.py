import psycopg2
import pandas as pd
import numpy as np


from sqlalchemy import create_engine
from dotenv import load_dotenv
import os


load_dotenv()


def conectar_db():
    """
    Conecta ao banco de dados PostgreSQL.
    """
    try:
        conn = psycopg2.connect(
            host = os.getenv('DB_HOST'),
            database = os.getenv('DATABASE'),
            user = os.getenv('POSTGRES_USER'),
            password = os.getenv('POSTGRES_PASSWORD'),
            port = os.getenv('DB_PORT')
        )
        print('Conexão com o PostgreSQL bem sucedida!')
        return conn

    except Exception as e:
        print(f'Erro ao conectar ao PostgresSQL: {e}')


def inserir_dados_ao_postgres(conn, df, nome_tabela):
    """
    Insere os dados do arquivo CSV após tratamento
    na tabela do PostgreSQL.

    conn.close(): Fecha a conexão.
    """
    try:
        engine = create_engine(f'postgresql://{os.getenv("POSTGRES_USER")}:{os.getenv("POSTGRES_PASSWORD")}@{os.getenv("DB_HOST")}/{os.getenv("DATABASE")}')
        df.to_sql(nome_tabela, engine, if_exists = 'replace', index = False)
        print('Dados inseridos na tabela com sucesso!')
    except Exception as e:
        print(f'Erro ao inserir dados no PostgresSQL: {e}')
