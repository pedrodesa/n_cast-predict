import pandas as pd
from Pipeline.ETL.transform import converter_para_datas


def test_converter_datas():

    df = pd.DatFrame(
        {
            'dataSintomas': [
                '2020-01-01',
                '2021-03-05',
                '2022-12-04',
                '2023-04-15',
            ],
            'variavel_um': [1, 2, 3, 4],
        }
    )

    converter_para_datas(df, 'dataSintomas', formato='%Y-%m-%d')

    assert df['dataSintomas'].dtypes == 'datetime'
