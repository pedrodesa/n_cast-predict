-- BANCOS DE DADOS

-- DBTITLE; bd cnie
CREATE DATABASE IF NOT EXISTS bd_cnie;


-- TABELAS

-- Tabela de dados brutos de SRAG
CREATE TABLE IF NOT EXISTS tb_covid (
	dt_sin_pri DATE,
	dt_digita DATE,
	classi_fin INTEGER,
    evolucao INTEGER,
	co_mun_res VARCHAR(5),
	sg_uf CHAR(2),
	co_mun_not VARCHAR(7),
    sg_uf_not CHAR(2),
	idade_nasc INT
);


-- Tabela resultados predição
CREATE TABLE IF NOT EXISTS tb_result_predicao (
	Time INTEGER,
	dt_event DATE,
	Median NUMERIC,
	LI NUMERIC,
	LS NUMERIC,
	LIb NUMERIC,
	LSb NUMERIC
);

