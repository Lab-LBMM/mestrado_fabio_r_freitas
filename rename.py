#Importa as bibliotecas
import os 
import pandas as pd

#Importa o arquivo de metadados
metadados = pd.read_table("metadados.tsv")
print(metadados.head())

#Caminho para o diretório onde os arquivos estão localizados
dir_path = "../Analysis/RawData/"
files = os.listdir(dir_path)

#Seleciona as colunas File_name e Sample_name que serão usadas para renomear os arquivos
file_names = metadados['File_name']
sample_names = metadados['Sample_name']

for old_name, new_name in zip(file_names, sample_names):
    #Concatenando o caminho da pasta com os arquivos 
    #Nomes antigos
    old = os.path.join(dir_path, old_name)
    #Nomes novos (usando o f-string)
    new = os.path.join(dir_path, f"{new_name}.fastq.gz")
    #Renomear
    os.rename(old, new)


