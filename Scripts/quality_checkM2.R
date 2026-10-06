library(readr)
library(openxlsx)
library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(scales)

#Definir caminho e o diretório de trabalho
path <- "/home/freitas/LBMM/Mestrado/Analysis/checkm2"
setwd(path)

checkM2 <- read_tsv("ecoevobio_quality_report.tsv")


Qualidade <- checkM2 %>% mutate(AMOSTRA = as.integer(str_extract(Name, "(?<=^S)\\d+"))) %>%
  mutate(Completeness_General = as.double(Completeness_General), Contamination = as.double(Contamination)) %>% 
  mutate(Qualidade = ifelse((Completeness_General >= 90.0 & Contamination <= 5.0), "1.High",
                            ifelse((Completeness_General >= 50.0 & Contamination <= 10.0), "2.Medium", "3.Low")))


Qualidade_cont_amostra <- Qualidade %>% group_by(AMOSTRA, Qualidade) %>% summarise(n_MAGs=n())
Qualidade_cont <- Qualidade %>% group_by(Qualidade) %>% summarise(n_MAGs=n())

contagem_geral <- Qualidade %>%
  count(Qualidade, name = "Total_MAGs") %>%
  mutate(Percentual = scales::percent(Total_MAGs / sum(Total_MAGs)))

print(contagem_geral)
write.xlsx(contagem_geral,"contagem_qualidade.xlsx" ) 

Qualidade_plot2 <- Qualidade %>% 
  ggplot(aes(x = Completeness_General, y = Contamination)) +
  geom_hline(yintercept = 5, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 90, linetype = "dashed", color = "grey40") +
  geom_point(aes(size = Genome_Size, color = Qualidade), alpha = 0.7) +
  
  scale_color_manual(
    name = "MAG quality",
    values = c("1.High" = "#1b9e77", "2.Medium" = "#d95f02", "3.Low" = "#7570b3"),
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

print(Qualidade_plot2)

# #Qualidade_plot2 <- Qualidade %>% ggplot() +
#   geom_point(aes(x = Completeness_General, y = Contamination, size = Genome_Size, color = Qualidade)) + 
#   geom_abline(intercept = 5, slope = 0, color = "darkblue") + geom_vline(xintercept = 90, color = "darkblue") +
#   theme_bw()
#print(Qualidade_plot2)

