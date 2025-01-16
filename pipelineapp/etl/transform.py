"""Módulo para transformar dados de variáveis."""

from datetime import datetime
from typing import List, Union

import pandas as pd


def var_nome_minusculo(data):
    """
    Altera os nomes das variáveis de maiúsculo para minúsculo.

    Args:
        data: pd.DataFrame
    """
    data.columns = data.columns.str.lower()

    return data


def selecionar_colunas(data, colunas):
    """
    Seleciona colunas de um dataframe a partir de uma lista.

    Args:
        data: pd.DataFrame
        colunas (list): lista com o nome das colunas
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
