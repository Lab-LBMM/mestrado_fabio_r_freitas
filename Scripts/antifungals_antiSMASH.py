#!/usr/bin/env python3

#Import libraries 
import argparse
import json
import os
import pandas as pd

def main():
    parser = argparse.ArgumentParser(description="Identify antifungals BGCs from antismash output")
    parser.add_argument("-v", "--version", action="version", version="%(prog)s 1.0.0")
    parser.add_argument("-a", "--antismash_dir", default="./", 
                        help="Path to the directory containing per-sample antiSMASH output folders")
    parser.add_argument("-p", "--pfam", default="./pfam.tsv", 
                        help="File with a list of PFAM domains")
    args = parser.parse_args()

    #Path to the antismash folder
    #antismash_output_path = args.antismash_dir
    antismash_results_path = "/home/freitas/LBMM/EvoEcoBio/antismash_ecoevobio_data/identified (teste)-20260927T214618Z-1-001/identified (teste)"
    pfam_list = "set"
    PFAM = []
    #Find the json file
    BGCs = {"Sample_file": {},
            }

    for root, dirs, files in os.walk(antismash_results_path):
        for f in files:
            if f.endswith(".json"):
                Sample = {"File": {f}}
                
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
                            #If there is a BGC, it will take the features
                            if "protoclusters" in area:
                                contig = record["id"]
                                protocluster = area["protoclusters"]
                                
                                Sample = {"File": {
                                                    f: {
                                                        contig: {"PFAM_list": PFAM }}}}
                               
                                #Save the start and the end positions of the protocluster in a tuple
                                protocluster_location = (area["start"], area["end"])

                                for feature in features:
                                    #Select just the PFAM_domain features from 
                                
                                    for area in record.get("areas", []):
                                        domain = select_domains(feature, protocluster_location)
                                        if domain:
                                            Sample["File"][f][contig]["PFAM_list"].append(domain)
                                        
                                
    print(Sample)
    #print(BGCs)

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
                domain = feature["qualifiers"]["db_xref"]
                
                return domain

main()


