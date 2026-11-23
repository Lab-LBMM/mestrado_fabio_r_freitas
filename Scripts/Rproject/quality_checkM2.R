#!/usr/bin/env Rscript

#Load the necessary packages
suppressPackageStartupMessages(
{library(readr)
library(openxlsx)
library(argparse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(scales)
library(purrr)
library(ggpmisc)
library(patchwork)
})

# Opens a window so the user can click and select the folder
parser <- ArgumentParser(prog= "quality_checkM2", description= "Analisys from checkM2 results")
parser$add_argument(
  "-v","--version",
  action="version",
  version="%(prog)s 1.0.0"
)

parser$add_argument(
  "-i", "--input",
  default = "./",
  help = "Input checkM2 report file or folder with several report files"
)

parser$add_argument(
  "-o", "--output",
  default = "./Results",
  help = "Path to output "
) 

parser$add_argument(
  "-f", "--folders",
  action = "store_true",
  default = FALSE,
  help = "Use this flag if you have a list of folders, each containing CheckM2 report files, and want to use the folder names as labels for the plots (Max lenght is 31 characters)"
)

parser$add_argument(
  "-rm", "--remove_pattern",
  default = "",
  help = "Remove a pattern from file names"
)

parser$add_argument(
  "-g", "--grid_columns",
  default = 2,
  type = "double",
  help = "Select the number of plot columns"
)

args <- parser$parse_args()

#Path to checkm2 results
path <- args$input
#Create a result folder
out_path <-paste0(args$output)
dir.create(out_path)

#List of files and path added to files
list_checkm2_path <- list.files(path, pattern ="quality_report.tsv" , full.names = TRUE, recursive = args$folders)
 if (args$folders){
  list_checkm2 <- dirname(list_checkm2_path) %>% basename()
  
} else {
  list_checkm2 <- basename(list_checkm2_path)}


#Import files
checkM2 <- list_checkm2_path %>% map(~read_tsv(., col_names = TRUE))

#Change file names
list_checkm2 <- list_checkm2 %>% map(~gsub(args$remove_pattern,"",.))
names(checkM2) <- list_checkm2

#Define quality of MAGs
checkM2_quality <- checkM2 %>% map(function(checkM2_df) {
  checkM2_df %>% mutate(SAMPLE = as.integer(str_extract(Name, "(?<=^S)\\d+"))) %>%
  mutate(Completeness_General = as.double(Completeness_General), Contamination = as.double(Contamination)) %>% 
  mutate(Quality = ifelse((Completeness_General >= 90.0 & Contamination <= 5.0), "1.High",
                            ifelse((Completeness_General >= 50.0 & Contamination <= 10.0), "2.Medium", "3.Low"))) %>% filter(Genome_Size <= 80000000) #80 Mb
})

#Count MAGs by quality
quality_count_sample <- checkM2_quality %>% map(~group_by(.,SAMPLE, Quality) %>% summarise(MAGs=n()))
quality_count <- checkM2_quality %>% map(~group_by(.,Quality) %>% summarise("Total MAGs"=n()) %>% 
                                  mutate(Percentual = scales::percent(`Total MAGs` / sum(`Total MAGs`))))

print(quality_count)
write.xlsx(quality_count,paste0(out_path,"/quality_count.xlsx")) 


#Create a table with the count of MAGs for each category to use in the table
count <- quality_count %>% map(function(df){
  df %>% mutate(Quality = str_remove(Quality, "[1-3]\\.")) %>% mutate(MAGs = paste0(df$'Total MAGs', " (", Percentual, ")")) %>%
    add_row(Quality = "Total", MAGs = paste0(as.character(sum(df$'Total MAGs')), " (100%)")) %>% select(Quality, MAGs)
})

#Create all individual plots for each checkM2 file
quality_plot2 <- pmap(list(checkM2_quality, list_checkm2, count), function(df, dfname, count_df){

  df %>%  ggplot(aes(x = Completeness_General, y = Contamination)) +
  geom_hline(yintercept = 5, linetype = "dashed", color = "grey20") +
  geom_vline(xintercept = 90, linetype = "dashed", color = "grey20") +
  geom_point(aes(size = Genome_Size, color = Quality), alpha = 0.7) +
    coord_cartesian(ylim = c(0, 100)) +
  
  scale_color_manual(
    name = "MAG quality",
    values = c("1.High" = "#7570b3", "2.Medium" = "#d95f02", "3.Low" = "gray40"),
    labels = c("High", "Medium", "Low"),
    limits = c("1.High", "2.Medium", "3.Low"), drop = FALSE
  ) +
    
    annotate(
      geom = "table_npc",
      npcx = 0.05, 
      npcy = 0.95, 
      label = list(count_df),
      size = 4,
      table.theme = ttheme_gtsimple()
    ) +
  
  # Changing to Mb:
  scale_size_continuous(
    name = "Size (Mb)",
    labels = function(x) paste0(round(x / 1e6, 2), " Mb"),
    limits = c(0, 600e6),
    breaks = c(0.5e6, 5e6, seq(10e6, 60e6, by = 20e6)),
    range = c(1, 8)
  ) +
  
  guides(color = guide_legend(override.aes = list(size = 4))) +
  labs(
    title = dfname,
    x = "Completeness (%)",
    y = "Contamination (%)"
  ) +
  theme_bw()
})

#Combine all plots
combined_plot <- wrap_plots(quality_plot2, ncol = args$grid_columns) + plot_layout(guides = "collect", axes = "collect")
combined_plot 
ggsave(filename = paste0(out_path, "/checkM2_scatterplot.png"), combined_plot, width = 16, height = 8)


