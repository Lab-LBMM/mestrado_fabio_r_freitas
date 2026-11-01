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

#Find the json file
antismash_json = []
for root, dirs, files in os.walk(antismash_results_path):
    for file in files:
        if file.endswith(".json"):
            json_path = os.path.join(root, file)
            antismash_json.append(json_path)

#Read the json file and save the content
for files in antismash_json:
    try:
        with open(files, "r") as file:
            content = json.load(file)
    except FileNotFoundError:
        print("File was not found")


print(content)
#records ---> features ---> region/protocluster
