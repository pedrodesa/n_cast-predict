# RUN COMMAND
# Rscript .src/rdata2csv.r

setwd('D:/n_cast-predict')



# Configuração de opções para tratamento de erros e warnings
options(warn = 1)  # Mostra warnings imediatamente
options(stringsAsFactors = FALSE)  # Previne conversão automática de strings para fatores

# Função auxiliar para verificar e criar diretório
create_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
    message("Diretório criado: ", path)
  }
  return(path)
}

# Função para processar um único arquivo
process_file <- function(file_path, output_dir) {
  tryCatch({
    message("\nProcessando arquivo: ", basename(file_path))
    
    # Cria um novo ambiente para carregar os dados
    # Isso evita conflitos com objetos existentes
    env <- new.env()
    load(file_path, envir = env)
    
    # Lista todos os objetos no ambiente
    objects <- ls(envir = env)
    
    if (length(objects) == 0) {
      warning("Nenhum objeto encontrado no arquivo: ", basename(file_path))
      return(NULL)
    }
    
    # Processa cada objeto
    for (obj_name in objects) {
      obj <- get(obj_name, envir = env)
      
      if (is.data.frame(obj)) {
        if (nrow(obj) > 0) {
          # Adiciona informações sobre o processamento
          attr(obj, "processed_time") <- Sys.time()
          attr(obj, "source_file") <- basename(file_path)
          
          # Define nome do arquivo de saída
          output_file <- file.path(output_dir, 
                                   paste0(obj_name, "_processado_", 
                                          format(Sys.time(), "%Y%m%d"), 
                                          ".csv"))
          
          # Salva o arquivo com tratamento de erro
          tryCatch({
            write.csv2(obj, output_file, row.names = FALSE)
            message("  Objeto '", obj_name, "' salvo em: ", basename(output_file))
          }, error = function(e) {
            warning("  Erro ao salvar objeto '", obj_name, "': ", e$message)
          })
        } else {
          warning("  O objeto '", obj_name, "' é um data.frame vazio.")
        }
      } else {
        message("  O objeto '", obj_name, "' não é um data.frame, ignorando.")
      }
    }
  }, error = function(e) {
    warning("Erro ao processar arquivo '", basename(file_path), "': ", e$message)
  })
}

# Função principal
main <- function() {
  # Define e cria diretórios
  data_dir <- "./data"
  output_dir <- create_dir(file.path(data_dir, "output"))
  
  # Lista arquivos .RData
  files <- list.files(path = data_dir, 
                      pattern = "\\.Rdata$", 
                      full.names = TRUE, 
                      ignore.case = TRUE)
  
  # Verifica se existem arquivos
  if (length(files) == 0) {
    stop("Nenhum arquivo .RData encontrado em: ", data_dir)
  }
  
  # Registra início do processamento
  message("Iniciando processamento de ", length(files), " arquivo(s)")
  start_time <- Sys.time()
  
  # Processa cada arquivo
  for (file in files) {
    process_file(file, output_dir)
  }
  
  # Registra fim do processamento
  end_time <- Sys.time()
  processing_time <- difftime(end_time, start_time, units = "mins")
  message("\nProcessamento concluído em ", round(processing_time, 2), " minutos")
}

# Executa o script
main()










## Lista todos os arquivos com extensão Rdata no diretório './data'
#files <- list.files(path = './data', pattern = '\\.Rdata$', full.names = TRUE)
#
## Verifica se há arquivos .Rdata no diretório
#if (length(files) == 0) {
#  stop("Nenhum arquivo .Rdata encontrado no diretório './data'.")
#}
#
## Verifica se a pasta de saída existe; caso contrário, cria a pasta
#output_dir <- './data/output'
#if (!dir.exists(output_dir)) {
#    # Cria o diretório, se ele não existir
#    dir.create(output_dir, recursive = TRUE)
#    message("Diretório de saída criado: ", output_dir)
#    }
#
## Processa cada arquivo individualmente
#for (file in files) {
#  message("Carregando dados do arquivo: ", file)
#  
#  # Carrega os objetos contidos no arquivo .Rdata
#  load(file) 
#  
#  # Obtém os objetos carregados no ambiente atual
#  objs <- mget(ls())
#  
#  # Processa cada objeto carregado
#  for (obj_name in names(objs)) {
#    obj <- objs[[obj_name]]
#    
#    # Verifica se o objeto é um data.frame
#    if (is.data.frame(obj) && nrow(obj) > 0) {
#      # Define o nome do arquivo CSV com base no nome do objeto
#      output_file <- file.path(output_dir, paste0(obj_name, "_tipo_alterado.csv"))
#      
#      # Escreve o data.frame no arquivo CSV
#      write.csv2(obj, output_file, row.names = FALSE)
#      message("Arquivo salvo com sucesso: ", output_file)
#    } else {
#      message("O objeto '", obj_name, "' não é um data.frame ou está vazio.")
#    }
#  }
#}
#

