library(readxl)
library(ggplot2)
library(ggpubr)

data_PT <- read_excel("C:/Users/Kim/Downloads/BT/plateassay_growthrates.xlsx")

p_1 <- ggboxplot(data_PT, x = "temperature", y = "mumax",
                 color = "temperature",
                 palette = c("#7fcdbb", "#fec44f", "#3182bd"),
                 add = "jitter", shape = "temperature") +
  ggtitle("Box plots with jittered points using plateassay growthrates")
p_1 <- ggboxplot(data_PT, x = "temperature", y = "mumax",
                 color = "temperature",
                 palette = "jco",
                 add = "jitter", shape = "temperature") +
  ggtitle("Box plots with jittered points using plateassay growthrates") 

p_1 <- ggboxplot(data_PT, x = "temperature", y = "mumax",
                 color = "temperature",
                 palette = c("#7fcdbb", "#fec44f", "#3182bd"),
                 add = "jitter", shape = "temperature",
                 rotate = TRUE) +
  ggtitle("Box plots with jittered points using plateassay growthrates")

# Specify the pairwise group comparisons
comps <- list(c("4", "9"), c("4", "13.5"), c("9", "13.5"))
p_1 <- p_1 +
  stat_compare_means(comparisons = comps) +
  stat_compare_means(label.y = 1.25) +
  labs(title = 
  "Box plots with a global p-value and p-values for pairwise comparisons")

# Specify the comparisons of interest
comps <- list(c("4", "9"), c("4", "13.5"), c("9", "13.5"))
p_1 <- p_1 +
  stat_compare_means(comparisons = comps, label = "p.signif") +
  stat_compare_means(label.y = 1.25) +
  labs(title = 
  "Box plots with significance levels for pairwise comparisons")

p_2 <- ggboxplot(data_PT, x = "temperature", y = "mumax", 
                 color = "temperature",
                 palette = c("#7fcdbb", "#fec44f", "#3182bd"),
                 ylab = "Maximal Growth Rate",
                 add = "jitter", shape = "temperature")
p_3 <- ggboxplot(data_PT, x = "photoperiod", y = "mumax", 
                 color = "photoperiod",
                 palette = c("#756bb1", "#fc9272", "#dd1c77"),
                 ylab = "Maximal Growth Rate",
                 add = "jitter", shape = "photoperiod")
combined_plot <- ggarrange(p_2, p_3,  ncol = 2, nrow = 1,
                           common.legend = FALSE, legend = "bottom")
