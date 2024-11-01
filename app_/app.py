from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import os
import uvicorn

app = FastAPI()

# Monta a pasta static para servir arquivos CSS e JavaScript
app.mount("/static", StaticFiles(directory="app_/static"), name="static")

# Configura o Jinja2 para renderizar templates da pasta templates
templates = Jinja2Templates(directory="app_/templates")

# Rota para a interface
@app.get("/", response_class=HTMLResponse)
async def get_index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# Rota para iniciar o pipeline
@app.post("/start-pipeline")
async def start_pipeline():
    try:
        # Comando para iniciar o pipeline
        os.system("python app_/pipelineapp/main.py")
        return {"status": "Pipeline iniciado com sucesso!"}
    except Exception as error:
        return {"status": "Failed to start pipeline", "error": str(error)}

