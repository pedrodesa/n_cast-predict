#Script para Nowcaster (UF, Faixa Etária e UF-Faixa)

#0 - Pacotes Necessários:
#0.1 - INLA
install.packages("INLA", 
                 repos=c(getOption("repos"), 
                         INLA="https://inla.r-inla-download.org/R/stable"),  
                 dep=TRUE)

#0.2 - NOWCASTER
if (!require(devtools)) install.packages('devtools') 
devtools::install_github("https://github.com/covid19br/nowcaster")

#0.3 - Lendo os Pacotes
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(INLA, nowcaster, ggplot2, dplyr, lubridate, aweek, dygraphs, xts, purrr, tidyr)

#1 - Importando bases de dados Covid e ajustando o banco

#1.2 - Banco 14/08          
conf_covid2 <- read.csv("./dados_14_08_24_nowcast (1).csv", sep= ";") #Apenas Confirmados Série 14/08

#1.2.1 - Ajustando Banco 14/08              
conf_covid2 <- conf_covid2 %>%
  mutate(dataInicioSintomas = as.Date(dataInicioSintomas)) %>%
  mutate(dataNotificacao = as.Date(dataNotificacao)) %>%
  filter(classificacaoFinal %in% c(1, 2))%>%
  filter(dataInicioSintomas <= as.Date("2024-08-01"))

#1.1.2 - Criando Faixas Etárias 14/08 
conf_covid2 <- conf_covid2 %>%
  mutate(Faixa = case_when(
    idade < 19 ~ "menor que 19",
    idade >= 20 & idade <=39 ~ "20 a 39",
    idade >= 40 & idade <=59 ~ "40 a 59",
    idade >= 60 & idade <=69 ~ "60 a 69",
    idade >= 70 & idade <=79 ~ "70 a 79",
    idade >= 80 ~ "80 ou mais"
  ))

#2 - Dividindo os bancos por agregação

#2.2 - Dividindo o banco de 14/08

#2.1.1 - UF
recortes_UF_b2 <- split(conf_covid2, conf_covid2$estadoIBGE)

#2.1.2 - Faixa
recortes_Faixa_b2 <- split(conf_covid2, conf_covid2$Faixa) 


#3 - Modelagem nowcaster


#3.1 - Lista de armazenamento de dos resultados Nowcast

#3.1.1 - Lista Resultados UF
resultados_nowcasting_UF <- list()

#3.1.2 - Lista Resultados Faixa
resultados_nowcasting_Faixa <- list() 

#3.2 - Nowcast UF (EstadoNotificacaoIBGE)  

for(estado in names(recortes_UF_b2)) {
  dados_estado <- recortes_UF_b2[[estado]]
  nowcast_UF <- nowcasting_inla(dataset = dados_estado,  
                                date_onset = "dataInicioSintomas",  
                                date_report = "dataNotificacao",  
                                data.by.week = TRUE,
                                Dmax = 6,
                                wdw = 12)  #Parametro aqui
  resultados_nowcasting_UF[[estado]] <- list(nowcast_UF = nowcast_UF)
}

str(resultados_nowcasting_UF)


#3.3 - Nowcast Faixa

for(Faixa in names(recortes_Faixa_b2)) {
  dados_Faixa <- recortes_Faixa_b2[[Faixa]]
  nowcast_Faixa <- nowcasting_inla(dataset = dados_Faixa,  
                                   date_onset = "dataInicioSintomas",  
                                   date_report = "dataNotificacao",  
                                   data.by.week = TRUE,
                                   Dmax = 6,
                                   wdw = 12)  #Parametro aqui
  resultados_nowcasting_Faixa[[Faixa]] <- list(nowcast_Faixa = nowcast_Faixa)
}


#4 - Ajustando Dados por SE

#4.1 - Listas de Armazenamento

#4.1.1 - UF

#4.1.1.1 - Banco 14/08
lista_series_semana_UF2 <- list() # Inicializar uma lista para armazenar os resultados do primeiro banco

#4.1.2 - Faixa

#4.1.1.1 - Banco 14/08
lista_series_semana_Faixa2 <- list() # Inicializar uma lista para armazenar os resultados do primeiro banco



#4.1 - Colocando em SE para as UF

#4.1.2 - Banco 14/08                     
for (estado in names(recortes_UF_b2)) {
  dados_estado_2 <- recortes_UF_b2[[estado]]
  serie_semana_2 <- dados_estado_2 %>%
    mutate(semana_epi = epiweek(dataInicioSintomas), 
           ano_epi = epiyear(dataInicioSintomas), 
           dt_event = aweek::get_date(semana_epi, ano_epi, start = 7)) %>%
    group_by(dt_event) %>%
    count()
  lista_series_semana_UF2[[estado]] <- serie_semana_2
}



#4.2 - Colocando em SE para as Faixa

#4.2.1 - Banco 01/08                     
for (Faixa in names(recortes_Faixa_b2)) {
  dados_Faixa_1 <- recortes_Faixa_b2[[Faixa]]
  serie_semana_1 <- dados_Faixa_1 %>%
    mutate(semana_epi = epiweek(dataInicioSintomas), 
           ano_epi = epiyear(dataInicioSintomas), 
           dt_event = aweek::get_date(semana_epi, ano_epi, start = 7)) %>%
    group_by(dt_event) %>%
    count()
  lista_series_semana_Faixa2[[Faixa]] <- serie_semana_1
}


#4.2.1 - Banco 14/08          
for (Faixa in names(recortes_Faixa_b2)) {
  dados_Faixa_2 <- recortes_Faixa_b2[[Faixa]]
  serie_semana_2 <- dados_Faixa_2 %>%
    mutate(semana_epi = epiweek(dataInicioSintomas), 
           ano_epi = epiyear(dataInicioSintomas), 
           dt_event = aweek::get_date(semana_epi, ano_epi, start = 7)) %>%
    group_by(dt_event) %>%
    count()
  lista_series_semana_Faixa2[[Faixa]] <- serie_semana_2
}


#5 - Plot
#5.1 - Listas de Armazenamento         

#5.1.1- UF
series_combinadas_UF <- list() #Séries

lista_graficos_UF <- list() #Gráfico

#5.1.2 - Faixa
series_combinadas_Faixa <- list() #Séries

lista_graficos_Faixa <- list() #Gráfico


#5.2 - Gerando Gráficos

#5.2.1- UF
for (uf in names(lista_series_semana_UF2)) {
  serie_uf <- lista_series_semana_UF2[[uf]]
  serie_xts <- xts(as.numeric(serie_uf$n), order.by = as.Date(serie_uf$dt_event))
  nowcast_uf <- resultados_nowcasting_UF[[uf]]
  now12_values <- as.numeric(nowcast_uf$nowcast_UF$total$Median)
  LI_values <- as.numeric(nowcast_uf$nowcast_UF$total$LI)
  LS_values <- as.numeric(nowcast_uf$nowcast_UF$total$LS)
  now12_xts <- xts(c(rep(NA, length(serie_xts) - length(now12_values)), now12_values), order.by = index(serie_xts))
  LI_xts <- xts(c(rep(NA, length(serie_xts) - length(LI_values)), LI_values), order.by = index(serie_xts))
  LS_xts <- xts(c(rep(NA, length(serie_xts) - length(LS_values)), LS_values), order.by = index(serie_xts))
  serie_combinada <- cbind(serie_xts, now12_xts, LI_xts, LS_xts)
  colnames(serie_combinada) <- c("Número de Casos", "Now12 - Mediana", "Now12 - LI", "Now12 - LS")
  series_combinadas_UF[[uf]] <- serie_combinada
  grafico <- dygraph(serie_combinada) %>%
    dySeries("Número de Casos", label = paste("Série -", uf), color = "blue", fillGraph = FALSE) %>%
    dySeries(c("Now12 - LI", "Now12 - Mediana", "Now12 - LS"), label = "Nowcasting (Intervalo de Confiança)", color = "green", fillGraph = TRUE) %>%
    dyOptions(stackedGraph = FALSE, fillAlpha = 0.2) %>%
    dyAxis("x", label = "Data de Início dos Sintomas") %>%
    dyAxis("y", label = "Número de Casos") %>%
    dyRangeSelector()
  lista_graficos_UF[[uf]] <- grafico
}


series_combinadas_Faixa <- list() #Séries

lista_graficos_Faixa <- list() #Gráfico

#5.2.2 - Faixa
for (Faixa in names(lista_series_semana_Faixa2)) {
  serie_fx <- lista_series_semana_Faixa2[[Faixa]]
  serie_xts_fx <- xts(as.numeric(serie_fx$n), order.by = as.Date(serie_fx$dt_event))
  nowcast_fx <- resultados_nowcasting_Faixa[[Faixa]]
  now12_values_fx <- as.numeric(nowcast_fx$nowcast_Faixa$total$Median)
  LI_values_fx <- as.numeric(nowcast_fx$nowcast_Faixa$total$LI)
  LS_values_fx <- as.numeric(nowcast_fx$nowcast_Faixa$total$LS)
  now12_xts_fx <- xts(c(rep(NA, length(serie_xts_fx) - length(now12_values_fx)), now12_values_fx), order.by = index(serie_xts_fx))
  LI_xts_fx <- xts(c(rep(NA, length(serie_xts_fx) - length(LI_values_fx)), LI_values_fx), order.by = index(serie_xts_fx))
  LS_xts_fx <- xts(c(rep(NA, length(serie_xts_fx) - length(LS_values_fx)), LS_values_fx), order.by = index(serie_xts_fx))
  serie_combinada_fx <- cbind(serie_xts_fx, now12_xts_fx, LI_xts_fx, LS_xts_fx)
  colnames(serie_combinada_fx) <- c("Número de Casos", "Now12 - Mediana", "Now12 - LI", "Now12 - LS")
  series_combinadas_Faixa[[uf]] <- serie_combinada_fx
  grafico_fx <- dygraph(serie_combinada_fx) %>%
    dySeries("Número de Casos", label = paste("Série -", Faixa), color = "blue", fillGraph = FALSE) %>%
    dySeries(c("Now12 - LI", "Now12 - Mediana", "Now12 - LS"), label = "Nowcasting (Intervalo de Confiança)", color = "green", fillGraph = TRUE) %>%
    dyOptions(stackedGraph = FALSE, fillAlpha = 0.2) %>%
    dyAxis("x", label = "Data de Início dos Sintomas") %>%
    dyAxis("y", label = "Número de Casos") %>%
    dyRangeSelector()
  lista_graficos_Faixa[[Faixa]] <- grafico_fx
}


grafico_fx


#############################
lista_graficos_UF$`21`

lista_graficos_Faixa$`40 a 59`
