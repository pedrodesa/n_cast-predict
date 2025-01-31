###########################################
# --- NOWCASTING MODEL

# Análise exploratória e modelagem de dados

# RUN COMMAND:
# Rscript.exe model_nowcast.r

###########################################

setwd('D:/n_cast-predict')

# 1.0 PACOTES UTILIZADOS ---

# install.packages('pacman')
pacman::p_load(tidyverse, aweek, dotenv)

# if (!require(devtools)) install.packages('devtools')
# devtools::install_github("https://github.com/covid19br/nowcaster")

# devtools::install_github("RcppCore/Rcpp")
# devtools::install_github("rstats-db/DBI")
# devtools::install_github("rstats-db/RPostgres")
# install.packages("RPostgres")

library(RPostgres)
library(DBI)
library(INLA)
library(nowcaster)
library(dotenv)


# 2.0 CONEXÃO COM O BANCO DE DADOS ---
# Variáveis de ambiente
dotenv::load_dot_env('./conf/set_env.r')

# Conexão com o PostgreSQL
# drv <- dbDriver("PostgreSQL")
conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv('DATABASE'),
  host = Sys.getenv('DB_HOST'),
  port = Sys.getenv('DB_PORT'),
  user = Sys.getenv('POSTGRES_USER'),
  password = Sys.getenv('POSTGRES_PASSWORD')
)


# Métodos

#1 - lista Dbs
dbListTables(conn)

#2 - lista campos
# dbListFields(conn, 'tb_esus_covid')

#3 - Read table
# dbReadTable(conn, "tb_esus_covid")

#3.1 - atribui dataframe
# db <- dbReadTable(conn, "tb_srag_st")

#4 - segunda forma de obter dataframe com consulta (QUERY)
r_query <- dbSendQuery(
  conn, 
  "SELECT datainiciosintomas, datanotificacao 
  FROM tb_esus_covid
  WHERE datainiciosintomas >= '2023-06-01' AND datainiciosintomas <= '2023-12-31';"
)

#4.1 Transforma a query em um data.frame
dados <- dbFetch(r_query, n = -1)

#LIMPA RESULTADOS
dbClearResult(r_query)

# Terminou o trabalho?
#5 Desconecte do banco de dados
dbDisconnect(conn)


# 3.0 TRANSFORMAR VARIÁVEIS ---
# dados$datainiciosintomas <- ymd(dados$datainiciosintomas)
# dados$datanotificacao <- ymd(dados$datanotificacao)

dados$datainiciosintomas <- as.Date(dados$datainiciosintomas)
dados$datanotificacao <- as.Date(dados$datanotificacao)



# 4.0 NOWCASTING ---
nowcast_df <- nowcasting_inla(dataset = dados,
                              date_onset = "datainiciosintomas",
                              date_report = "datanotificacao",
                              data.by.week = TRUE,
                              Dmax = 6,
                              wdw = 12,
                              control.compute=list(config = TRUE))

# head(nowcast_df$total)


# 5.0 TRANSFORMAR OS DADOS EM SÉRIE TEMPORAL
serie_semana <- dados |>
  mutate(semana_epi = epiweek(datainiciosintomas),
         ano_epi = epiyear(datainiciosintomas),
         dt_event = aweek::get_date(semana_epi, ano_epi, start = 7)) |>
  group_by(dt_event) |>
  count() |>
  dplyr::filter(dt_event >= '2023-01-01' ) # usando dado da semana 26/2021


# 6.0 VISUALIZAÇÃO DO NOWCASTING
# ggplot(data = nowcast_df$total, aes(
#   x = dt_event, y = Median, col = 'Nowcast', )
# ) +
#   geom_ribbon(aes(
#     ymin = LI, ymax = LS, col = NA
#   ), alpha = 0.2, show.legend = F
#   ) +
#   geom_line()+
#   geom_line(data = serie_semana, aes(
#     dt_event, y = n, col = 'Observado')
#   ) +
#   theme_bw()+
#   theme(
#     legend.position = "bottom", 
#     axis.text.x = element_text(angle = 90)
#   ) +
#   scale_color_manual(
#     values = c('grey50', 'black'), name = ''
#   ) +
#   scale_x_date(
#     date_breaks = '2 weeks', date_labels = '%V/%y', name = 'Data Semanas'
#   ) +
#   labs(x = '', y = 'Nº Casos')
