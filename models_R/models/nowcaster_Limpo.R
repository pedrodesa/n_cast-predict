#Script Modelagem NowCaster

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
          library(INLA)
          library(nowcaster)
          library(ggplot2)
          library(dplyr)
          library(lubridate)
          library(aweek)
          library(dygraphs)
          library(xts)

#1 - Base de dados

   #1.1 - Importando base covid

        #1.1.1 - Banco 01/08
                 conf_covid <- read.csv("C:/Users/luska/Downloads/dados_nowcaster.csv", sep= ",") #Apenas Confirmados Série 01/08

        #1.1.2 - Banco 15/08
                 conf_covid2 <- read.csv("C:/Users/luska/Downloads/dados_14_08_24_nowcast (1).csv", sep= ";") #Apenas Confirmados Série 14/08

  #1.2 - Selecionando variáveis

       #1.2.1 - Conhecendo as variáveis e ajustando o banco

              #1.2.1.1 - Banco 01/08
                         head(conf_covid)
                         summary(conf_covid)

                         conf_covid <- conf_covid %>%
                                       mutate(dataInicioSintomas = as.Date(dataInicioSintomas)) %>%
                                       mutate(dataNotificacao = as.Date(dataNotificacao)) %>%
                                       filter(dataInicioSintomas <= as.Date("2024-08-01"))

                         summary(conf_covid)

              #1.2.1.2 - Banco 14/08
                         conf_covid2 <- conf_covid2 %>%
                                        mutate(dataInicioSintomas = as.Date(dataInicioSintomas)) %>%
                                        mutate(dataNotificacao = as.Date(dataNotificacao)) %>%
                                        filter(classificacaoFinal %in% c(1, 2))%>%
                                        filter(dataInicioSintomas <= as.Date("2024-08-01"))


  #1.3 - Ajustando Série Histórica

       #1.3.1 - Banco 01/08
                serie_historica <- conf_covid  %>%
                                   group_by(dataInicioSintomas) %>%
                                   summarise(n = n())

       #1.3.2 - Banco 01/08
                serie_historica2 <- conf_covid2  %>%
                                    group_by(dataInicioSintomas) %>%
                                    summarise(n = n())


#2 - Modelagem Nowcasting

   #2.1 - Modelagem com 8 semanas
          nowcast_covid8 <- nowcasting_inla(dataset = conf_covid,
                                            date_onset = "dataInicioSintomas",
                                            date_report = "dataNotificacao",
                                            data.by.week = T,
                                            Dmax = 6,
                                            wdw = 8)
   #2.2 - Modelagem com 12 semanas
          nowcast_covid12 <- nowcasting_inla(dataset = conf_covid,
                                             date_onset = "dataInicioSintomas",
                                             date_report = "dataNotificacao",
                                             data.by.week = T,
                                             Dmax = 6,
                                             wdw = 12)

   #2.3 - Modelagem com 15 semanas
          nowcast_covid15 <- nowcasting_inla(dataset = conf_covid,
                                             date_onset = "dataInicioSintomas",
                                             date_report = "dataNotificacao",
                                             data.by.week = T,
                                             Dmax = 6,
                                             wdw = 15)

   #2.4 - Modelagem com 30 semanas
          nowcast_covid30 <- nowcasting_inla(dataset = conf_covid,
                                             date_onset = "dataInicioSintomas",
                                             date_report = "dataNotificacao",
                                             data.by.week = T,
                                             Dmax = 6,
                                             wdw = 30)



   #2.5 - Ajustando série para SE

        #2.5.1 - Série de 01/08
                 serie_semana <- conf_covid %>%
                                 mutate(semana_epi = epiweek(dataInicioSintomas),
                                        ano_epi = epiyear(dataInicioSintomas),
                                        dt_event = aweek::get_date(semana_epi,ano_epi,start = 7))  %>%
                                 group_by(dt_event) %>%
                                 count()

        #2.5.2 - Série de 14/08
                 serie_semana2 <- conf_covid2 %>%
                                  mutate(semana_epi = epiweek(dataInicioSintomas),
                                         ano_epi = epiyear(dataInicioSintomas),
                                         dt_event = aweek::get_date(semana_epi,ano_epi,start = 7))  %>%
                                  group_by(dt_event) %>%
                                  count()


   #2.6 - Testando o Modelo

        #2.6.1 - Calculando Diferenças

               #2.6.1.1 - Banco de Modelagem (01/08)
                          a <- nowcast_covid8$total$Median
                          b <- nowcast_covid12$total$Median
                          c <- nowcast_covid15$total$Median
                          d <- nowcast_covid30$total$Median
                          esperado <- tail(serie_semana$n, 6)

                          erro8 <- a-esperado
                          erro12 <- b-esperado
                          erro15 <- c-esperado
                          erro30 <- d-esperado

               #2.6.1.2 - Banco de Teste (14/08)
                          a2 <- head(tail(nowcast_covid8$total$Median,6), 6)
                          b2 <- head(tail(nowcast_covid12$total$Median,6), 6)
                          c2 <- head(tail(nowcast_covid15$total$Median,6), 6)
                          d2 <- head(tail(nowcast_covid30$total$Median,6), 6)
                          esperado2 <- head(tail(serie_semana2$n, 6), 6)

                          erro82 <- a2-esperado2
                          erro122 <- b2-esperado2
                          erro152 <- c2-esperado2
                          erro302 <- d2-esperado2

        #2.6.2 - Erro Quadratico Médio

               #2.6.2.1 - Banco de Modelagem (01/08)
                          EQM8 <- sum(erro8^2)/length(erro8)
                          EQM12 <- sum(erro12^2)/length(erro12)
                          EQM15 <- sum(erro15^2)/length(erro15)
                          EQM30 <- sum(erro30^2)/length(erro30)

               #2.6.2.2 - Banco de Teste (14/08)
                          EQM82 <- sum(erro82^2)/length(erro82)
                          EQM122 <- sum(erro122^2)/length(erro122)
                          EQM152 <- sum(erro152^2)/length(erro152)
                          EQM302 <- sum(erro302^2)/length(erro302)

        #2.6.3 - Erro Médio Relativo

               #2.6.3.1 - Banco de Modelagem (01/08)
                          EMR8 <- sum(abs(erro8)/esperado)/length(erro8)*100
                          EMR12 <- sum(abs(erro12)/esperado)/length(erro12)*100
                          EMR15 <- sum(abs(erro15)/esperado)/length(erro15)*100
                          EMR30 <- sum(abs(erro30)/esperado)/length(erro30)*100

               #2.6.3.2 - Banco de Teste (14/08)
                          EMR82 <- sum(abs(erro82)/esperado2)/length(erro82)*100
                          EMR122 <- sum(abs(erro122)/esperado2)/length(erro122)*100
                          EMR152 <- sum(abs(erro152)/esperado2)/length(erro152)*100
                          EMR302 <- sum(abs(erro302)/esperado2)/length(erro302)*100

        #2.6.4 - Tabela de Erros
                 eqm1 <- round(c(EQM8, EQM12, EQM15, EQM30), digits = 0)
                 eqm2 <- round(c(EQM82, EQM122, EQM152, EQM302), digits = 0)
                 emr1 <- round(c(EMR8, EMR12, EMR15, EMR30), digits = 1)
                 emr2 <- round(c(EMR82, EMR122, EMR152, EMR302), digits = 1)

                 tabela <- data.frame(EQM_1 = eqm1,
                                      EQM_2 = eqm2,
                                      EMR_1 = emr1,
                                      EMR_2 = emr2)

                 rownames(tabela) <- c("Now 8", "Now 12", "Now 15", "Now 30")

                 colnames(tabela) <- c("EQM 01/08", "EQM 14/08", "EMR 01/08", "EMR14/08")

                 print(tabela)

#3 - Plot

   #3.1 - Ajustando para o formato xts
          serie1_xts <- xts(serie_semana$n, order.by = as.Date(serie_semana$dt_event) + 1)
          serie2_xts <- xts(serie_semana2$n, order.by = as.Date(serie_semana2$dt_event) + 1)
          now8_xts <- xts(nowcast_covid8$total$Median, order.by = as.Date(nowcast_covid8$total$dt_event))
          now12_xts <- xts(nowcast_covid12$total$Median, order.by = as.Date(nowcast_covid12$total$dt_event))
          now15_xts <- xts(nowcast_covid15$total$Median, order.by = as.Date(nowcast_covid15$total$dt_event))
          now30_xts <- xts(nowcast_covid30$total$Median, order.by = as.Date(nowcast_covid30$total$dt_event))
          LI_xts <- xts(nowcast_covid30$total$LI, order.by = as.Date(nowcast_covid30$total$dt_event))
          LS_xts <- xts(nowcast_covid30$total$LS, order.by = as.Date(nowcast_covid30$total$dt_event))

   #3.2 - Ajustando os objetos para o plot
          serie_combinada <- cbind(serie1_xts, serie2_xts,now8_xts,now12_xts,now15_xts,now30_xts,LI_xts,now30_xts ,LS_xts)
          colnames(serie_combinada) <- c("Série 01/08", "Série 14/08","Now8","Now12","Now15","Now30","Lower","Median" ,"Upper")

   #3.3 - Plotando
          dygraph(serie_combinada) %>%
          dySeries("Série 01/08", label = "Série 01/08", color = "blue", fillGraph = FALSE) %>%
          dySeries("Série 14/08", label = "Série 14/08", color = "red", fillGraph = FALSE) %>%
          dySeries("Now8", label = "Now8", color = "green", fillGraph = FALSE) %>%
          dySeries(c("Lower", "Median", "Upper"), label = "(Intervalo de Confiança)", color = "pink", fillGraph = FALSE) %>%
          dySeries("Now12", label = "Now12", color = "yellow", fillGraph = FALSE) %>%
          dySeries("Now15", label = "Now15", color = "gray", fillGraph = FALSE) %>%
          dySeries("Now30", label = "Now30", color = "pink", fillGraph = FALSE) %>%
          dyOptions(stackedGraph = FALSE, fillGraph = TRUE, fillAlpha = 0.2) %>%
          dyAxis("x", label = "Data de Início dos Sintomas") %>%
          dyAxis("y", label = "Número de Casos") %>%
          dyRangeSelector()

