""" Módulo com todos os tratamentos necessários para consilidar os dados de entrada """

import pandas as pd


def converter_para_data(df, colunas, formato = None):
    """
    Converte colunas do tipo string para o tipo data.

    type: datetime64[ns]
    """
    for coluna in colunas:
        df[coluna] = pd.to_datetime(df[coluna], format = formato)

    return df


def renomear_colunas(df, colunas):
    """
    Renomeia uma ou mais colunas de um dataframe.

    Args:
        df (pandas.DatFrame): pandas DatFrame.
        colunas (dict): Dicionário onde as chaves
        são as colunas atuais e os valores são os
        novos nomes.
    """
    return df.rename(columns = colunas)
