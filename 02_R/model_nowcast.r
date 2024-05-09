# Pacotes

# if (!require(devtools)) install.packages('devtools')
# devtools::install_github("https://github.com/covid19br/nowcaster")

# install.packages('pacman')
pacman::p_load(tidyverse, aweek)

# install.packages("devtools")
# devtools::install_github("RcppCore/Rcpp")
# devtools::install_github("rstats-db/DBI")
# devtools::install_github("rstats-db/RPostgres")


library(RPostgres)
library(DBI)
library(INLA)
library(nowcaster)
library(dotenv)


dotenv::load_dot_env('set_env.r')


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
dbListFields(conn, 'tb_srag_st')

#3 - Read table
dbReadTable(conn, "tb_srag_st")

#3.1 - atribui dataframe
# db <- dbReadTable(conn, "tb_srag_st")

#4 - segunda forma de obter dataframe com consulta
r_query <- dbSendQuery(conn, 
                       "SELECT dt_sin_pri, dt_digita 
                       FROM tb_srag_st
                       WHERE dt_sin_pri >= '2022-08-01' AND dt_sin_pri <= '2022-12-31';")


# Transforma a query em um data.frame
df <- dbFetch(r_query, n = -1)

str(df)
glimpse(df)#LIMPA RESULTADOS

dbClearResult(conn)

#terminou o trabalho?
dbDisconnect(conn)

dados = df

dados$dt_sin_pri <- as.Date(dados$dt_sin_pri)
dados$dt_digita <- as.Date(dados$dt_digita)

# Nowcasting
nowcast_df <- nowcasting_inla(dataset = dados,
                              date_onset = "dt_sin_pri",
                              date_report = "dt_digita",
                              data.by.week = TRUE)

head(nowcast_df$total)


serie_semana <- dados |>
  mutate(semana_epi = epiweek(dt_sin_pri),
         ano_epi = epiyear(dt_sin_pri),
         dt_event = aweek::get_date(semana_epi, ano_epi, start = 7)) |>
  group_by(dt_event) |>
  count() |>
  dplyr::filter(dt_event >= '2021-01-01' ) # usando dado da semana 26/2021



ggplot(data=nowcast_df$total,
       aes(x = dt_event, y = Median,
           col = 'Nowcast', )) +
  geom_ribbon(aes(ymin = LI, ymax = LS, col = NA),
              alpha = 0.2,
              show.legend = F)+
  geom_line()+
  geom_line(data = serie_semana,
            aes(dt_event,
                y = n,
                col = 'Observado'))+
  theme_bw()+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90)) +
  scale_color_manual(values = c('grey50', 'black'),
                     name = '')+
  scale_x_date(date_breaks = '2 weeks',
               date_labels = '%V/%y',
               name = 'Data Semanas')+
  labs(x = '',
       y = 'Nº Casos')
