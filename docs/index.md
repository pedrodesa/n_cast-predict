# Projeto Nowcasting

## Objetivo
O projeto tem o objetivo de proporcionar uma ferramenta analítica para predição da correção de atrasos de notificações de casos de doenças/agravos de importância para a saúde pública.

## Arquitetura

### Ingestão de dados
O arquivo de dados é inserido pela área técnica no repositório inicial, em seguida é consumido pelo sistema para o processo de ETL.

### ETL
Processo de Extract, Transform e Load.

<img src="img/etl.png" alt="Processo de ETL" style="height: 350px; width:900px;" />

### Modelos estatísticos
A metodologia estatística utilizada foram os modelos nowcasting.

### Visualização 
* **Relatórios automatizados:** relatórios epidemiológicos com as estimativas do nowcasting.
* **Dashboard:** dashboards analíticos para consumo interno pela área de negócios.

![Pipeline](img/pipeline.png)

## Banco de dados
Foi criado um modelo relacional para a ingestão dos dados no banco dados.

<img src="img/modelo_relacional.jpg" alt="Modelo Relacional" style="height: 500px; width: 500px;" />