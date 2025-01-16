# Sistema de Modelos Nowcasting

## Objetivo
Gerar predições de atrasos de registros de vigilância em saúde, para antecipação de eventos de interesse para a saúde pública.


![Pipeline](/relatorios/img/pipeline.png)


## Download do projeto
```
git clone https://github.com/pedrodesa/n_cast-predict
```

## Ativar ambiente virtual
```
# Linux
source .venv/bin/activate

# Windows
.venv/Scripts/activate
```

## Instalações das bibliotecas
```
pip install -r requirements.txt
```

## Executar o pipeline
```
python app_/pipelineapp/main.py
```

## Executar web app
```
uvicorn app_.app:app --reload
```

Para parar a execução do web app use Ctrl + C
