#Importa as bibliotecas
import os 
import pandas as pd
import argparse

#argparse options
parser = argparse.ArgumentParser(prog= "rename",
                                 description= "Rename fastq.gz files based on a metadata table")
parser.add_argument("-v", "--version", action="version", version="%(prog)s 1.0.0" )
parser.add_argument("-m", "metadata", default="./metadados.tsv", help="Metadata table containing two columns: File_name with current names and Sample_name with the new names")
parser.add_argument("-i", "--input", default="./", help="Folder with fastq.gz files")
args = parser.parse_args()

#Read metadata table
metadados = pd.read_table(args.metadata)
print(metadados.head())

#Folder with fastq.gz files
dir_path = args.input
files = os.listdir(dir_path)

#Select columns File_name and Sample_name that will be used to change names
file_names = metadados['File_name']
sample_names = metadados['Sample_name']

for old_name, new_name in zip(file_names, sample_names):
    #Join the folder path with files path
    #Old names
    old = os.path.join(dir_path, old_name)
    #New names
    new = os.path.join(dir_path, f"{new_name}.fastq.gz")
    #Rename
    os.rename(old, new)


