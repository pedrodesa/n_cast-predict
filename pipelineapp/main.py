"""Módulo de execução do pipeline."""

# RUN COMMAND ---
# python pipelineapp/main.py

import glob
import os
import yaml

import rpy2.robjects as robjects
from etl.extract import ler_arquivo
from etl.load import conectar_db, inserir_dados_no_postgres
from etl.transform import (converter_para_datas, selecionar_colunas,
                           var_nome_minusculo)


with open('config.yml', 'r') as file:
    config = yaml.safe_load(file)


# Run Rscript
R_SCRIPT_PATH = config['paths']['r_script_path']
robjects.r.source(R_SCRIPT_PATH)
"""
Executa o R script para alterar o formato do arquivo de Rdata para CSV.
"""


def executar_pipeline():
    """
    Executar o pipeline completo.
    """
    # ler arquivo

    # Define o caminho do diretório
    PATH_DIRECTORY = config['paths']['path_directory']

    # Verifica se o diretório existe
    if os.path.exists(PATH_DIRECTORY):
        # Encontra arquivos CSV no diretório
        PATH_FILE_CSV = glob.glob(os.path.join(PATH_DIRECTORY, '*.csv'))

        if PATH_FILE_CSV:
            # Le o primeiro arquivo CSV encontrado
            dados = ler_arquivo(PATH_FILE_CSV[0], separador=';')
        else:
            print('Nenhum arquivo foi encontrado no diretório.')
    else:
        print(f'O diretório "{PATH_DIRECTORY}" não existe.')

    # Nomes para minúsculo
    dados = var_nome_minusculo(dados)

    # Selecionar colunas
    lista_colunas = [
        'datainiciosintomas',
        'datanotificacao',
        'estadoibge',
        'idade',
    ]

    dados = selecionar_colunas(dados, lista_colunas)

    # converter colunas string para data
    dados = converter_para_datas(
        dados, ['datainiciosintomas', 'datanotificacao'], formato='%Y-%m-%d'
    )

    # Exportar dados para o PostgreSQL
    nome_tabela = 'tb_esus_covid'

    # Conecta-se ao PostgreSQL
    conn = conectar_db()

    # Insere os dados do DataFrame na tabela PostgreSQL
    if conn is not None:
        inserir_dados_no_postgres(conn, dados, nome_tabela)

        # Fechar a conexão
        conn.close()


if __name__ == '__main__':
    executar_pipeline()
