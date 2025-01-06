"""Módulo de execução do pipeline."""

# RUN COMMAND ---
# python pipelineapp/main.py

from etl.extract import ler_arquivo
from etl.load import conectar_db, inserir_dados_no_postgres
from etl.transform import selecionar_colunas, converter_para_datas, var_nome_minusculo


def executar_pipeline():
    """
    Executar o pipeline completo.
    """
    # ler arquivo
    path = './data/dados.csv'
    dados = ler_arquivo(path, separador=';')

    # Nomes para minúsculo
    dados = var_nome_minusculo(dados)

    # Selecionar colunas
    lista_colunas = ['datainiciosintomas', 'datanotificacao', 'estadoibge', 'idade']

    dados = selecionar_colunas(dados, lista_colunas)

    # converter colunas string para data
    dados = converter_para_datas(
        dados, ['datainiciosintomas', 'datanotificacao'], formato='%Y-%m-%d'
    )

    # Alterar nomes de colunas
    # novos_nomes = {'co_mun_res': 'co_mun_res', 'co_mun_not': 'co_mun_not'}
    # dados = renomear_colunas(dados, novos_nomes)

    # Exportar dados para o PostgreSQL
    nome_tabela = 'tb_covid'

    # Conecta-se ao PostgreSQL
    conn = conectar_db()

    # Insere os dados do DataFrame na tabela PostgreSQL
    if conn is not None:
        inserir_dados_no_postgres(conn, dados, nome_tabela)

        # Fechar a conexão
        conn.close()


if __name__ == '__main__':
    executar_pipeline()
