from extract import ler_arquivo
from transform import (converter_para_data, renomear_colunas)
from load import (conectar_db, inserir_dados_ao_postgres)


# ler arquivo
path = './data/Dados_Srag.csv'
dados = ler_arquivo(path, separador = ';')

# converter colunas string para data
dados = converter_para_data(
    dados,
    ['dt_sin_pri', 'dt_digita'],
    formato = '%d/%m/%Y'
)

# Alterar nomes de colunas
novos_nomes = {'co_mun_res': 'co_mun_res5',
               'co_mun_res.1': 'co_mun_res7'}
dados = renomear_colunas(dados, novos_nomes)




nome_tabela = 'tb_srag_st'

# Conecta-se ao PostgreSQL
conn = conectar_db()

# Insere os dados do DataFrame na tabela PostgreSQL
if conn is not None:
    inserir_dados_ao_postgres(conn, dados, nome_tabela)

    # Fecha a conexão
    conn.close()


'''
def pipeline_completa():

    data = ler_arquivo()
    data = converter_para_data()
    data = renomear_colunas()

    def insert2database():
        conn = conectar_db()
        if conn is not None:
            inserir_dados_ao_postgres(conn, data, nome_tabela)

            conn.close()
'''
