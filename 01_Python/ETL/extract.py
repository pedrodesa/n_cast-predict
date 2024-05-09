import pandas as pd


def ler_arquivo(file, separador=None):
    """
    Lê um arquivo de dados em CSV de um diretório local.
    """

    data = pd.read_csv(file, delimiter=separador)
    df = pd.DataFrame(data)

    return df
