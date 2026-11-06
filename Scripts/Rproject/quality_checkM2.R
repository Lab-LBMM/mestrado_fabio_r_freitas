
#Load the necessary packages
{library(readr)
library(openxlsx)
library(argparse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(scales)
library(purrr)
library(patchwork)
}

# Opens a window so the user can click and select the folder
parser <- ArgumentParser()

parser$add_argument(
  "-i",
  "--input",
  default = "./",
  help = "Input checkM2 report file or folder with several report files"
) 

args <- parser$parse_args()

#Path to checkm2 results
path <- args$input
path <- "/home/freitas/LBMM/Mestrado/Analysis/3.Binning/checkM2"
out_path <-paste0(path,"Results/")

dir.create(out_path)

#List of files and path added to files
list_checkm2 <- list.files(path, pattern = "quality_report.tsv")
list_checkm2_path <- file.path(path, list_checkm2)

#Import files
checkM2 <- list_checkm2_path %>% map(~read_tsv(., col_names = TRUE))
filename <- list_checkm2 %>% map(~gsub("_quality_report.tsv","",.))
names(checkM2) <- filename

#Define quality of MAGs
quality <- checkM2 %>% map(function(checkM2_df) {
  checkM2_df %>% mutate(SAMPLE = as.integer(str_extract(Name, "(?<=^S)\\d+"))) %>%
  mutate(Completeness_General = as.double(Completeness_General), Contamination = as.double(Contamination)) %>% 
  mutate(Quality = ifelse((Completeness_General >= 90.0 & Contamination <= 5.0), "1.High",
                            ifelse((Completeness_General >= 50.0 & Contamination <= 10.0), "2.Medium", "3.Low")))
})

#Count MAGs by quality
quality_count_sample <- quality %>% map(~group_by(.,SAMPLE, Quality) %>% summarise(MAGs=n()))
quality_count <- quality %>% map(~group_by(.,Quality) %>% summarise("Total MAGs"=n()) %>% 
                                  mutate(Percentual = scales::percent(`Total MAGs` / sum(`Total MAGs`))))

print(quality_count)
write.xlsx(quality_count,paste0(out_path,"quality_count.xlsx")) 


#Create all individual plots for each checkM2 file
quality_plot2 <- map2(quality,  filename, function(df, dfname){

  df %>%  ggplot(aes(x = Completeness_General, y = Contamination)) +
  geom_hline(yintercept = 5, linetype = "dashed", color = "grey20") +
  geom_vline(xintercept = 90, linetype = "dashed", color = "grey20") +
  geom_point(aes(size = Genome_Size, color = Quality), alpha = 0.7) +
  
  scale_color_manual(
    name = "MAG quality",
    values = c("1.High" = "#7570b3", "2.Medium" = "#d95f02", "3.Low" = "gray40"),
    labels = c("High", "Medium", "Low"),
    limits = c("1.High", "2.Medium", "3.Low"), drop = FALSE
  ) +
  
  # Alteração para número normal / Mb:
  scale_size_continuous(
    name = "Size (Mb)",
    labels = function(x) paste0(round(x / 1e6, 2), " Mb"),
    limits = c(0, 600e6),
    breaks = seq(0.5e6, 50e6, by = 10e6),
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
combined_plot <- wrap_plots(quality_plot2, ncol = 2) + plot_layout(guides = "collect", axes = "collect")
combined_plot 
ggsave(filename = paste0(out_path, "checkM2_scatterplot.png"), combined_plot)

#plot_all <- quality_plot2 %>% map(~print(.))


