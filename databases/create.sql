-- BANCOS DE DADOS

-- DBTITLE
CREATE DATABASE IF NOT EXISTS bd_nowcast_covid;

-- TABELAS

-- Tabela de dados do e-SUS Notifica
CREATE TABLE IF NOT EXISTS tb_esus_covid (
	datainiciosintomas DATE,
	datanotificacao DATE,
	estadoibge INTEGER,
    idade INTEGER
);

-- Tabela da série de semanas epidemiológicas
CREATE TABLE IF NOT EXISTS tb_serie_semana_epi (
	datainiciosintomas DATE,
	estadoibge INTEGER,
    faixaetaria VARCHAR,
	datamodelagem DATE
);

-- Tabela da série observada de semanas epidemiológicas
CREATE TABLE IF NOT EXISTS tb_serie_semana_epi_obs (
	datainiciosintomas DATE,
	estadoibge INTEGER,
    faixaetaria VARCHAR,
	datamodelagem DATE,
	CONSTRAINT pk_id PRIMARY KEY (estadoibge, faixaetaria, datamodelagem)
);

-- Tabela transformada para semanas epidemiológicas
CREATE TABLE IF NOT EXISTS tb_nowcasting (
	Time INTEGER,
	dt_event DATE,
	Median NUMERIC,
	LI NUMERIC,
	LS NUMERIC,
	LIb NUMERIC,
	LSb NUMERIC,
	estadoibge INTEGER,
	faixaetaria VARCHAR,
	datamodelagem DATE,
	CONSTRAINT fk_id FOREIGN KEY (estadoibge, faixaetaria, datamodelagem)
	REFERENCES tb_serie_semana_epi_obs (estadoibge, faixaetaria, datamodelagem)
);