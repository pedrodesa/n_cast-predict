from datetime import datetime

import numpy as np
import pandas as pd

from pipelineapp.etl.transform import (converter_para_datas,
                                       selecionar_colunas, var_nome_minusculo)


def test_var_nome_minusculo():
    """
    Testa se os nomes das variáveis foram alterados de maiúsculo para minúsculo.
    """
    nomes_maiusculo = pd.DataFrame(
        {'COLUNA1': ['Valor1', 'VALOR2'], 'Coluna2': [3, 4]}
    )

    resultado = var_nome_minusculo(nomes_maiusculo)

    resultado_esperado = pd.DataFrame(
        {'coluna1': ['Valor1', 'VALOR2'], 'coluna2': [3, 4]}
    )

    assert all(
        col.islower() for col in resultado.columns
    ), 'Nomes das colunas devem estar em minúsculo'

    pd.testing.assert_frame_equal(resultado, resultado_esperado)


def test_selecionar_colunas():
    """
    Testa se as colunas corretas estão sendo selecionadas.
    """
    df1 = pd.DataFrame({'col1': [1, 2], 'col2': [3, 4], 'col3': [5, 6]})

    colunas = ['col1', 'col2']

    df2 = selecionar_colunas(df1, colunas)

    colunas_df1 = df1.columns[:2]
    colunas_df2 = df2.columns

    assert len(df1.columns) != len(
        df2.columns
    ), 'Número de colunas deve ser diferente'

    assert colunas_df1.isin(
        colunas_df2
    ).all(), 'Os nomes das colunas deve ser o mesmo nos dois dataframes'
