#from ETL.extract import ler_arquivo
from .utils import gerar_dados

dados_teste = gerar_dados()

print(dados_teste.head())


