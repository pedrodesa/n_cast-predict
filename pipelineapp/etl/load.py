"""Módulo para inserir dados no banco de dados."""

import os
from functools import wraps
from datetime import datetime
import pytz
import psycopg2
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
import pandas as pd


def acessar_dotenv(func):
    """
    Load arquivo dot env.
    """
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
        return None


def verificar_tabela_existe(engine, nome_tabela):
    """
    Verifica se a tabela existe no banco de dados.
    """
    try:
        with engine.connect() as connection:
            query = text(f"""
                SELECT EXISTS (
                         SELECT FROM information_schema.tables
                         WHERE table_name = '{nome_tabela}'
                         );
                    """)
            result = connection.execute(query)
            return result.scalar()
    except Exception as error:
        print(f'Erro ao verificar a existência da tabela: {error}')
        return False
    
def criar_tabela(engine, nome_tabela, data):
    """
    Cria a tabela de dados no 
    """
    try:
        # Mapeia os tipos de dados do pandas para o PostgreSQL
        dtype_mapping = {
            'object': 'TEXT',
            'int64': 'INTEGER',
            'float64': 'FLOAT',
            'datetime64[ns]': 'TIMESTAMP',
            'bool': 'BOOLEAN'
        }

        # Gera o SQL para criar a tabela
        columns = []
        for column, dtype in data.dtypes.items():
            pg_type = dtype_mapping.get(str(dtype), 'TEXT')
            columns.append(f'"{column}" {pg_type}')

        create_table_sql = f"""
            CREATE TABLE IF NOT EXISTS {nome_tabela} (
                {', '.join(columns)}
            );
        """

        with engine.connect() as connection:
            connection.execute(text(create_table_sql))
            connection.commit()
            print(f'Tabeça {nome_tabela} criada com sucesso!')

    except Exception as error:
        print(f'Erro ao criar tabela: {error}')


def limpar_tabela(engine, nome_tabela):
    """
    Limpa todos os dados da tabela.
    """
    try:
        with engine.connect() as connection:
            connection.execute(text(f"TRUNCATE TABLE {nome_tabela};"))
            connection.commit()
            print(f'Dados da tabela {nome_tabela} foram limpos com sucesso!')
    except Exception as error:
        print(f'Erro ao limpar tabela: {error}')


@acessar_dotenv
def inserir_dados_no_postgres(conn, data, nome_tabela):
    """
    Insere os dados do arquivo CSV após tratamento
    na tabela do PostgreSQL.

    conn.close(): Fecha a conexão.
    """
    try:
        # Criar engine do SQLAlchemy
        engine = create_engine(
            f'postgresql://{os.getenv("DB_USER")}:'
            f'{os.getenv("DB_PASSWORD")}@{os.getenv("DB_HOST")}:'
            f'{os.getenv("DB_PORT")}/{os.getenv("DATABASE")}'
        )

        # verifica se a tabela existe
        if not verificar_tabela_existe(engine, nome_tabela):
            criar_tabela(engine, nome_tabela, data)
        else:
            # Se a tabela existe, limpa os dados
            limpar_tabela(engine, nome_tabela)

        data.to_sql(nome_tabela, engine, if_exists='append', index=False)
        print(f'Dados inseridos na tabela {nome_tabela} com sucesso!')

    except Exception as error:
        print(f'Erro ao inserir dados no PostgresSQL: {error}')
