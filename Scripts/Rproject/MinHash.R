#!/usr/bin/env Rscript

#Import packages
suppressPackageStartupMessages(
  {
    library(dplyr)
    library(stringr)
    library(tidyverse)
    library(pheatmap)
    library(ggplot2)
    library(argparse)
  })

parser <- ArgumentParser(prog="MinHash_heatmap", description="Plot the heatmap from distances results from Mash")
parser$add_argument(
  "-v","--version",
  action="version",
  version="%(prog)s 1.0.0"
)

parser$add_argument(
  "-i", "--input",
  default = "distances.tsv",
  help = "Path to the Mash distances output file"
  )

args <- parser$parse_args()

#Save file name and output
file_name <- basename(args$input) %>% gsub(".tsv", "", .)
output <- dirname(args$input)

#Import distances.tsv from Mash
data <- read.table(args$input, comment.char = '', 
                   header = TRUE ) %>% 
  rename(X = X.query) 

#Remove pattern other than sample names
data$X <- str_remove_all(data$X, "minhash/")
data$X <- str_remove_all(data$X, ".fastq.gz")

names <- c("X", data[,1])

#Chance columns names
colnames(data) <- names

#Set column X as row names
data <- column_to_rownames(data, var="X")

#Plot heatmap
H <- pheatmap(data)
ggsave(filename = paste0(output,"/",file_name,"_","Mash.png"), plot = H)
print(H)