#!/usr/bin/env python3

#Import libraries 
import argparse
import json
import os
import pandas as pd

parser = argparse.ArgumentParser(description="Identify antifungals BGCs from antismash output")
parser.add_argument("-a", "--antismash_dir", default="./", 
                    help="Path to the directory containing per-sample antiSMASH output folders")
args = parser.parse_args()

#Path to the antismash folder
#antismash_output_path = args.antismash_dir
antismash_results_path = "/home/freitas/LBMM/EvoEcoBio/antismash_ecoevobio_data/identified (teste)-20260927T214618Z-1-001/identified (teste)"
pfam_list = ""

#Find the json file
BGCs = []
for root, dirs, files in os.walk(antismash_results_path):
    for f in files:
        if f.endswith(".json"):
            #Retrive the path to the json found
            json_path = os.path.join(root, f)
            print(f)
            #Read the json file and save the content
            with open(json_path, "r") as file:
                antismash_data = json.load(file)
                #Content that will be saved
                for record in antismash_data.get("records", []):
                    print(record["id"])





    #for feature in record["features"]:
    # if tiver region




#print(antismash["records"][0:])

#if 


#print(content)
#select records ---> features ---> type: region/protocluster, salvar record idnos selecionados :type: pfam ---> qualifiers ---> db_xref