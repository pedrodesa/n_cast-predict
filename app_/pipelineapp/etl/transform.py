"""Módulo para transformar dados de variáveis."""

from datetime import datetime


def selecionar_colunas(data, colunas):
    """
    Seleciona colunas de uma dataframe.
    """
    data = data[colunas]

    return data


def converter_para_datas(data, colunas, formato=None):
    """
    Converte colunas do tipo string para o tipo data.

    type: datetime64[ns]
    """
    for coluna in colunas:
        data[coluna] = data[coluna].apply(
            lambda x: datetime.strptime(x, formato)
        )

    return data


def renomear_colunas(data, colunas):
    """
    Renomeia uma ou mais colunas de um dataframe.

    Args:
        df (pandas.DatFrame): pandas DatFrame.
        colunas (dict): Dicionário onde as chaves
        são as colunas atuais e os valores são os
        novos nomes.
    """
    return data.rename(columns=colunas)
