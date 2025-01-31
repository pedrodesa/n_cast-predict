# RUN COMMAND ---
# python models_R/run_models.py

import glob
import os
os.environ['R_HOME'] = r"C:\Program Files\R\R-4.1.3"

import yaml
import rpy2.robjects as robjects


with open('./conf/config.yml', 'r') as file:
    config = yaml.safe_load(file)


# Run Rscript
R_MODELS_PATH = config['paths']['r_models_path']
robjects.r.source(R_MODELS_PATH)
"""
Executa o R script para alterar o formato do arquivo de Rdata para CSV.
"""