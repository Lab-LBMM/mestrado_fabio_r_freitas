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

## Change names
names <- files_list %>% map(~gsub("_kraken2_report.txt.gz","",.))
names(kreports) <- names
kreports <- map2(kreports, names, function(df, name){
  df %>% rename(!!name := Percentage)
})

##Filter before plotting

#All domains and unclassified
overall <- kreports %>% map(~filter(., Taxon_rank == "D" | Taxon_rank == "U") %>% select(1,Classification))
 
#Bacteria
#line_domains <- kreports %>% map(~which(.$Taxon_rank == "D"))
#line_bac <- kreports %>% map(~which(.$TaxID == 2))
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
  theme_minimal(base_size = 12)
ggsave("kraken2_plot.png", plot = overall_plot)
print(overall_plot)
