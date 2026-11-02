#!/usr/bin/env python3

#Import libraries 
import argparse
import json
import os
import pandas as pd

def main():
    parser = argparse.ArgumentParser(description="Identify antifungals BGCs from antismash output")
    parser.add_argument("-a", "--antismash_dir", default="./", 
                        help="Path to the directory containing per-sample antiSMASH output folders")
    parser.add_argument("-p", "--pfam", default="./pfam.tsv", 
                        help="File with a list of PFAM domains")
    args = parser.parse_args()

    #Path to the antismash folder
    #antismash_output_path = args.antismash_dir
    antismash_results_path = "/home/freitas/LBMM/EvoEcoBio/antismash_ecoevobio_data/identified (teste)-20260927T214618Z-1-001/identified (teste)"
    pfam_list = "set"

    #Find the json file
    BGCs = []
    for root, dirs, files in os.walk(antismash_results_path):
        for f in files:
            if f.endswith(".json"):
                #Retrive the path to the json found
                json_path = os.path.join(root, f)
                #Read the json file and save the content
                with open(json_path, "r") as file:
                    antismash_data = json.load(file)

                    #Content that will be saved
                    for record in antismash_data.get("records", []):

                        features = record.get("features", [])
                        areas = record.get("areas")

                        #Find if there is a BGC on the contig and where starts and ends
                        for area in areas:

                            if "protoclusters" in area:
                                #Save the start and the end positions of the protocluster in a tuple
                                protocluster_location = (area["start"], area["end"])
                                print(f, record["id"],protocluster_location)

                                for feature in features:
                                    #Select just the PFAM_domain features from 
                                    #print(feature)
                                    print(select_domains(feature, protocluster_location))
                                
                                    for area in record.get("areas", []):
                                        BGCs.append({
                                        "Sample_file": f,
                                        "ID": record["id"],
                                        "BGC": area["protoclusters"],
                                        "PFAM_domains": select_domains(feature, protocluster_location)
                                              })
                                

    print(BGCs)

def location(feature_loc):
    #take the string and devide by start and end positions, besides DNA_strand
    position = feature_loc.replace("[", "").split(":")
    position[1] = position[1].split("]")
    
    DNA_strand = position[1][1]
    #List with start and end positions, besides DNA_strand
    genomic_loc = [int(position[0]), int(position[1][0]), DNA_strand]
    return genomic_loc

    
def select_domains(feature, BCG_loc):
    #Selects only the features within the protocluster
    feat_start = location(feature["location"])[0]
    feat_end = location(feature["location"])[1]
    if feat_start >= BCG_loc[0] and feat_end <= BCG_loc[1]:
        #Selects only the PFAM_domain features
        if feature["type"] == "PFAM_domain":
                domain_list = feature["qualifiers"].get("db_xref")
                return domain_list

main()

