#Libraries
import os 
import pandas as pd
import argparse

#Ask the user for the paths ---> ARGPARSE
#path_checkM2_output = input("Give the path for the quality report from checkM2: ")
checkM2_path = "Data/VAMB_MEGAHIT_assembly_host_removed_k21_141_10/checkm2_assembly_host_rm/quality_report.tsv"
log_path = "Data/VAMB_MEGAHIT_assembly_host_removed_k21_141_10/VAMB_host_rm_assembly/log.txt"
MAGs_dir_path = "Data/VAMB_MEGAHIT_assembly_host_removed_k21_141_10/VAMB_host_rm_assembly/bins"

#Import quality data from checkM2
bins_table = pd.read_table(checkM2_path)
print(bins_table)

#select just the necessary columns
bins_table = bins_table[["Name", "Completeness_General", "Contamination", "Genome_Size"]]
print(bins_table)

##read VAMB log for retrive samples order

#Empty list to fill with the order and samples name
order = []
#read the file
with open(log_path, "r") as file:
    #Read every read
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


#Split in two columns by the :
samples_order[["order", "samples"]] = samples_order.iloc[1:, 0].str.split(":", expand=True)
samples_order = samples_order[["order", "samples"]].iloc[1:]
#Remove the .tsv and white spaces from the samples name
samples_order["samples"] = samples_order["samples"].str.replace(".tsv", "").str.replace(" ", "")
print(samples_order)


#Rename all MAGs from the Binning output directory
MAGs_files = os.listdir(MAGs_dir_path)

for file in (MAGs_files):
    new_name = file.replace("S")
    #concatenat old name and the files path
    old_name = os.path.join(MAGs_dir_path, file)



#pattern to insert on the MAG name to identify the test
pattern = "VMH-a-htrm_k21"
#os.rename()

#Filtering for quality - medium and high quality MAGs
HighMedium_Quality = bins_table[(bins_table["Completeness_General"] >= 50) & (bins_table["Contamination"] <= 10)]
N_bins = len(HighMedium_Quality)

print(f" >>>> There are {N_bins} MAGs of Medium or High Quality")

#Create a new directory and move the medium and high quality MAGs

#os.makedirs


