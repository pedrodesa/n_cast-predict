# Modelos de Nowcating e Séries Temporais

Adaptado de: Oswaldo G Cruz

### Projeto de modelagem estatística para predição precoce de emergências.

## Stack
### Este projeto utiliza linguagem R e Python
* R: pacotes INLA e Nowcaster

## Instalação de pacotes R

### INLA

```r
install.packages("INLA",
repos=c(getOption("repos"),
INLA="https://inla.r-inla-download.org/R/stable"),
dep=TRUE)

library(INLA)
```

Para testar o INLA utilize o script abaixo

```r
n <- 100; a <- 1; b <- 1; tau <- 100
z <- rnorm(n)
eta <- a + b*z
scale <- exp(rnorm(n))
prec <- scale*tau
y <- rnorm(n, mean = eta, sd = 1/sqrt(prec))
data <- list(y=y, z=z)
formula <- y ~ 1+z
result <- inla(formula, family = "gaussian", data = data)
```

Para verificar use
```r
summary(result)
```

### Nowcaster

```r
if (!require(devtools)) install.packages('devtools')
devtools::install_github("https://github.com/covid19br/nowcaster")
```

### Testar o Nowcaster

```r
library(nowcaster)
data(sragBH) #carrega o dado
head(sragBH) #exibe as primeiras linhas
```

```r
nowcast_bh <- nowcasting_inla(dataset = sragBH,
date_onset = "DT_SIN_PRI",
date_report = "DT_DIGITA",
data.by.week = T)
```


```r
head(nowcast_bh$total)
# A tibble: 6 × 7
Time dt_event Median LI LS LIb LSb
<int> <date> <dbl> <dbl> <dbl> <dbl> <dbl>
1 17 2021-12-13 444 442 448 443 445
2 18 2021-12-20 632 627 641 630 635
3 19 2021-12-27 736 727 750 733 741
4 20 2022-01-03 759 746 777 754 765
5 21 2022-01-10 879 861 903. 872 887
6 22 2022-01-17 786 765. 813 778 795
```


```r
serie_semana <- sragBH |>
mutate(semana_epi = epiweek(DT_SIN_PRI),
ano_epi = epiyear(DT_SIN_PRI),
dt_event = aweek::get_date(semana_epi,ano_epi,start = 7)) |>
group_by(dt_event) |>
count() |>
dplyr::filter(dt_event >= '2021-07-04' ) # usando dado da semana 26/2021
```


```r
ggplot(data=nowcast_bh$total,
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
```


## Pipeline - ETL


