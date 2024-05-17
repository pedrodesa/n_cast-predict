"""Módulo para o pipeline de dados."""

from pipelineapp.etl import pipeline

# RUN COMMAND ---
# python 01_Python/main.py


def main():
    """
    Executa o pipeline completo.
    """
    pipeline.executar_pipeline()


if __name__ == '__main__':
    main()
