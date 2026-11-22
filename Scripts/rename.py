#Importa as bibliotecas
import os 
import pandas as pd
import argparse

#argparse options
parser = argparse.ArgumentParser(prog= "rename",
                                 description= "Rename fastq.gz files based on a metadata table")
parser.add_argument("-v", "--version", action="version", version="%(prog)s 1.0.0" )
parser.add_argument("-m", "metadata", default="./metadados.tsv", help="metadata table containing two columns: File_name and Sample_name")
parser.add_argument("-i", "--input", default="./", help="Folder with fastq.gz files")
args = parser.parse_args()

#Importa o arquivo de metadados
metadados = pd.read_table(args.metadata)
print(metadados.head())

#Caminho para o diretório onde os arquivos estão localizados
dir_path = args.input
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


