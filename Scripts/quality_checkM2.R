
#Load the necessary packages
{library(readr)
library(openxlsx)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(scales)
library(purrr)}

#Path to checkm2 results
path <- "/home/freitas/LBMM/Mestrado/Analysis/checkm2/"

#List of files and path added to files
list_checkm2 <- list.files(path, pattern = "_quality_report.tsv")
list_checkm2_path <- file.path(path, list_checkm2)

#Import files
checkM2 <- list_checkm2_path %>% map(~read_tsv(., col_names = TRUE))
names(checkM2) <- list_checkm2 %>% map(~gsub("_quality_report.tsv","",.))

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
write.xlsx(quality_count,paste0(path,"quality_count.xlsx")) 

quality_plot2 <- quality %>%
  ggplot(aes(x = Completeness_General, y = Contamination)) +
  geom_hline(yintercept = 5, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 90, linetype = "dashed", color = "grey40") +
  geom_point(aes(size = Genome_Size, color = quality), alpha = 0.7) +
  
  scale_color_manual(
    name = "MAG quality",
    values = c("1.High" = "#7570b3", "2.Medium" = "#d95f02", "3.Low" = "gray"),
    labels = c("High", "Medium", "Low")
  ) +
  
  # Alteração para número normal / Mb:
  scale_size_continuous(
    name = "Size (Mb)",
    labels = function(x) paste0(round(x / 1e6, 2), " Mb"),
    range = c(2, 6)
  ) +
  
  guides(color = guide_legend(override.aes = list(size = 4))) +
  labs(
    x = "Completeness (%)",
    y = "Contamination (%)"
  ) +
  theme_bw()

print(quality_plot2)


