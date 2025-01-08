# RUN COMMAND
# Rscript .src/rdata2csv.r

setwd('D:/n_cast-predict')

# Lista todos os arquivos com extensão Rdata no diretório './data'
files <- list.files(path = './data', pattern = '\\.Rdata$', full.names = TRUE)

# Verifica se há arquivos .Rdata no diretório
if (length(files) == 0) {
  stop("Nenhum arquivo .Rdata encontrado no diretório './data'.")
}

# Verifica se a pasta de saída existe; caso contrário, cria a pasta
output_dir <- './data/output'
if (!dir.exists(output_dir)) {
    # Cria o diretório, se ele não existir
    dir.create(output_dir, recursive = TRUE)
    message("Diretório de saída criado: ", output_dir)
    }

# Processa cada arquivo individualmente
for (file in files) {
  message("Carregando dados do arquivo: ", file)
  
  # Carrega os objetos contidos no arquivo .Rdata
  load(file) 
  
  # Obtém os objetos carregados no ambiente atual
  objs <- mget(ls())
  
  # Processa cada objeto carregado
  for (obj_name in names(objs)) {
    obj <- objs[[obj_name]]
    
    # Verifica se o objeto é um data.frame
    if (is.data.frame(obj) && nrow(obj) > 0) {
      # Define o nome do arquivo CSV com base no nome do objeto
      output_file <- file.path(output_dir, paste0(obj_name, "_tipo_alterado.csv"))
      
      # Escreve o data.frame no arquivo CSV
      write.csv2(obj, output_file, row.names = FALSE)
      message("Arquivo salvo com sucesso: ", output_file)
    } else {
      message("O objeto '", obj_name, "' não é um data.frame ou está vazio.")
    }
  }
}
