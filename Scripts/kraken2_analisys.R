#!/usr/bin/env Rscript

############ kraken2(PlusPFP) Analisys ############
###################################################
              
#Autor: Fábio Rodrigo de Freitas
#Date: 22/09/2026
              
#Libraries
suppressPackageStartupMessages(
{library(argparse)
 library(readr)
 library(R.utils)
 library(dplyr)
 library(tidyr)
 library(purrr)
 library(ggplot2)})

# # create parser object
# parser <- ArgumentParser()
# 
# #Argument for input
# parser$add_argument(
#   "-i",
#   "--input",
#   type = "character",
#   default = "./",
#   help = "Path to input folder with report files from Kraken2"
# )
# 
# parser$add_argument(
#   "-f",
#   "--folders",
#   action = "store_true",
#   default = FALSE,
#   help = "Use this flag for a list of folders where each contains a sample's Kraken2 report file"
# )
# 
# # get command line options, if help option encountered print help and exit,
# # otherwise if options not found on command line then set defaults,
# args <- parser$parse_args()
# 
# dir_path <- args$input

dir_path <- "/home/genomaa/Resultados/0.Outros/M/kraken2_pluspfp_cleaned"

##Get the list of files with path
files_path <- list.files(path = dir_path, pattern = "report.txt",
                         full.names = TRUE, recursive = TRUE ) #recursive = args$folders
files_list <- basename(files_path)

##Import input files with the colnames
kreports <- files_path %>% map(~read_tsv(., col_names = c("Percentage", "Reads", "Reads_taxon", "Taxon_rank", "TaxID", "Classification")))

## Change namos of each dataframe inside the lists based on the file name
names <- files_list %>% map(~gsub("_kraken2_report.txt.gz","",.))
names(kreports) <- names
kreports <- map2(kreports, names, function(df, name){
  df %>% rename(!!name := Percentage)
})

##Filter before plotting

#All domains and unclassified
overall <- kreports %>% map(~filter(., Taxon_rank == "D" | Taxon_rank == "U") %>% select(1,Classification))
 
#Bacteria
bacteria <- map(kreports, function(df){
  
line_domains <- which(df$Taxon_rank == "D")
line_bac <- which(df$TaxID == 2)
index_bac <- line_domains[line_bac == line_domains]
print(index_bac)

print(line_domains )
})
#next_domain <- kreports %>% map(function(df) {}  )

#Bac %>% kreports %>% map(~filter(., Taxon_rank == ))

##Plots
#All domains and unclassified
overall_join <- overall %>% reduce(~full_join(.x,.y, by = "Classification", .)) %>% 
  relocate(Classification, .before = everything()) %>% pivot_longer(cols = -Classification)
overall_join$Classification <- gsub("unclassified", "Unclassified",overall_join$Classification)

#overall_join <- overall_join 
#Bar plot
overall_plot <- overall_join %>% 
  ggplot(aes(x = name, fill = Classification, weight = value)) + 
  geom_bar() + scale_fill_viridis_d(option = "G", direction = -1) +
  labs(x = "Samples", y = "Relative Abundance (%)") + 
  theme_minimal(base_size = 12) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("kraken2_plot.png", plot = overall_plot)
print(overall_plot)
