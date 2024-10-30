-- BANCOS DE DADOS

-- DBTITLE; bd cnie
CREATE DATABASE IF NOT EXISTS bd_cnie;


-- TABELAS

-- Tabela de dados brutos de SRAG
CREATE TABLE IF NOT EXISTS tb_covid (
	dt_sin_pri DATE NULL,
	dt_digita DATE NULL,
	classi_fin INTEGER NULL,
    evolucao INTEGER NULL,
	co_mun_res VARCHAR(5) NULL,
	sg_uf CHAR(2) NULL,
	co_mun_not VARCHAR(7) NULL,
    sg_uf_not CHAR(2) NULL,
	idade_nasc INT NULL
);


-- Tabela resultados predição
CREATE TABLE IF NOT EXISTS tb_result_predicao (
	Time INTEGER NULL,
	dt_event DATE NULL,
	Median NUMERIC NULL,
	LI NUMERIC NULL,
	LS NUMERIC NULL,
	LIb NUMERIC NULL,
	LSb NUMERIC NULL
);
