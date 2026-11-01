#!/usr/bin/env python3

#Libraries
import argparse
import pandas as pd
import os
import re
import shutil

#Define command-line arguments for user input
parser = argparse.ArgumentParser(prog="MAGs_filt",description="Filters bins with high and medium quality and modifies the name assigned by VAMB")
parser.add_argument("-r","--checkM2_report", default="./quality_report.tsv",
                     help="Path to checkM2 quality report file. Include all the name of the file, e.g. quality_report.tsv")
parser.add_argument("-l", "--log", default="./log.txt",
                     help= "Path to the VAMB log file. Include all the name of the file, e.g. log.txt" )
parser.add_argument("-i", "--input", default="./bins",
                     help= "Path to the VAMB bins folder.")
parser.add_argument("-o", '--out_dir', default="./",
                     help= "Path to the output folder.")
parser.add_argument("-p","--pattern", default="", 
                    help="Pattern to be added to the end of the folder name and the bin files.")

args = parser.parse_args()


#path to the files and folders 
checkM2_path = args.checkM2_report
log_path = args.log
MAGs_dir_path = args.input
output_dir = args.out_dir

#pattern to insert on the MAG name to identify the test
TEST = args.pattern

#Import quality data from checkM2  
bins_table = pd.read_table(checkM2_path)

##read VAMB log for retrive samples order
#Empty list to fill with the order and samples name
order = []
#read the file
with open(log_path, "r") as file:
    #Read every line
    lines = file.readlines()
    for line in lines:
        #Take just the lines with the samples order
        if ".tsv" in line and ":" in line and "CLI args" not in line:
            #Remove the first part 
            sample_line = line.split("|")[-1].strip()
            #Insert every line match in the list
            order.append(sample_line)

#Transform in a dataframe
samples_order = pd.DataFrame(order)

#Split in two columns by the and mantain just the necessary
samples_order[["order", "samples"]] = samples_order.iloc[1:, 0].str.split(":", expand=True)
samples_order = samples_order[["order", "samples"]].iloc[1:]

#Transform the order series into int and  1 is added to make the index equal to that used by VAMB file names
samples_order["order"] = samples_order["order"].astype(int) + 1

#Remove the .tsv and white spaces from the samples name
samples_order["samples"] = samples_order["samples"].str.replace(".tsv", "").str.replace(" ", "")
#Transform the order series in the index of the dataframe
samples_order = samples_order.set_index("order")
print(samples_order)

##Rename each bin file from the Binning output directory
MAGs_files = os.listdir(MAGs_dir_path)
Samples_name_map = {}
for file in (MAGs_files):
    if match := re.search(r"S[0-9]+C", file):
        #Take the number between S and C on VAMB file name
        VAMB_index = file.split("C")[0].replace("S","")
        VAMB_index = int(VAMB_index)
        #Sample name of the file based on the index and order retrived from VAMB
        SAMPLE = samples_order.loc[VAMB_index, "samples"]
        #print(f"\nindex - {VAMB_index}", "\nSample name -->", SAMPLE) #Used to verify if the index match with the sample name
        #Replace the VAMB sample name by the real sample name, mantaining the contig identifier. The test ID is also inserted.
        new_name = re.sub(r"S[0-9]+C", f"{SAMPLE}C", file).replace(".fna", f"_{TEST}.fna")
        #Build a map for create a new column on the input table with the new name corresponding to the VAMB
        Samples_name_map[file.replace(".gz", "")] = new_name

        #concatenat old name and the files path
        old_name_path = os.path.join(MAGs_dir_path, file)
        #concatenat new name and the files path
        new_name_path = os.path.join(MAGs_dir_path, new_name)

        #Rename files just if the old name exists yet
        if os.path.exists(old_name_path):
            print(f"{file} ----> {new_name}")
            os.rename(old_name_path, new_name_path)
        elif os.path.exists(new_name_path):
            print(f"The name {file} isn't a VAMB file name. The file name may have already been changed.")

bins_table["New_name"] = bins_table["Name"].map(Samples_name_map).replace(".fna",".fna.gz")

#Filtering for quality - medium and high quality MAGs
HighMedium_Quality = bins_table[(bins_table["Completeness_General"] >= 50) & (bins_table["Contamination"] <= 10)]
N_bins = len(HighMedium_Quality)

print(f" \n>>>> There are {N_bins} MAGs of Medium or High Quality")

#Create a new directory and move the medium and high quality MAGs
os.makedirs(f"{output_dir}_{TEST}", exist_ok=True)

#Write the old name and the new name of all MAGs
bins_table = bins_table[["Name","New_name"]]
bins_table.to_csv(f"{output_dir}_{TEST}/bin_names.tsv", sep="\t")

#Write a tsv file with the result of the filtering
HighMedium_Quality = HighMedium_Quality.set_index("Name")
HighMedium_Quality.to_csv(f"{output_dir}_{TEST}/HighMedium_checkM2.tsv", sep="\t")

#Move fasta files of bins with high and medium quality
for file in (HighMedium_Quality["New_name"]):
    
    old_path = os.path.join(MAGs_dir_path, file)
    new_path = os.path.join(f"{output_dir}_{TEST}", file)
    shutil.move(old_path, new_path)