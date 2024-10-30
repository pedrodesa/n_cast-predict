"""Módulo para o pipeline de dados."""

from etl import pipeline

# RUN COMMAND ---
# python pipelineapp/main.py


def main():
    """
    Executa o pipeline completo.
    """
    pipeline.executar_pipeline()


if __name__ == '__main__':
    main()
