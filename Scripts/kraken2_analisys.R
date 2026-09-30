############ kraken2(PlusPFP) Analisys ############
###################################################
              
#Autor: Fábio Rodrigo de Freitas
#Date: 22/09/2026
              
#Libraries
{library(readr)
 library(R.utils)
 library(dplyr)
 library(tidyr)
 library(purrr)
 library(ggplot2)}

#Working directory
dir_path <- "/home/freitas/LBMM/Mestrado/Analysis/kraken2_pluspfp_reports"

##Get the list of files with path
files_list <- list.files(path = dir_path, pattern = "report.txt")
files_path <- file.path(dir_path, files_list)

##Import input files with the colnames
kreports <- files_path %>% map(~read_tsv(., col_names = c("Percentage", "Reads", "Reads_taxon", "Taxon_rank", "TaxID", "Classification")))
names(kreports) <- files_list %>% map(~gsub("_kraken2_report.txt.gz","",.))
##Filter before plotting
#All domains and unclassified
overall <- kreports %>% map(~filter(., Taxon_rank == "D" | Taxon_rank == "U"))
 
#Bacteria
line_domains <- kreports %>% map(~which(.$Taxon_rank == "D"))
line_bac <- kreports %>% map(~which(.$TaxID == 2))
next_domain <- kreports %>% map(function(df) {
  
}
  )

#Bac %>% kreports %>% map(~filter(., Taxon_rank == ))

##Plots
#All domains and unclassified
overall %>% map(~join_by())
overall_plot <- overall %>% ggplot(aes())

