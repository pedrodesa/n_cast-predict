import random

import pandas as pd
from faker import Faker


def gerar_dados():
    """
    Gera dados de teste.

    type: df: pd.DataFrame
    """
    faker = Faker('pt_BR')

    data = {
        'dataSintomas': [
            faker.date_between_dates(
                date_start = pd.to_datetime('2023-01-01'),
                date_end = pd.to_datetime('2023-04-30')
            )
            for _ in range(10)
        ],
        'idade': [round(random.uniform(18, 65), 2) for _ in range(10)]
    }

    df = pd.DataFrame(data)
    df['dataSintomas'] = pd.to_datetime(df['dataSintomas'])

    return df
