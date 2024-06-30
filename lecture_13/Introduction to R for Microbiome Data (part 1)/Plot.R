install.package("ggpubr")
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
# Specify the pairwise group comparisons
comps <- list(c("4", "9"), c("4", "13.5"), c("9", "13.5"))

# Plot 1: Violin plot with boxplot inside, standard p-value labels
plot1 <- ggviolin(data_PT, x = "temperature", y = "mumax", fill = "temperature",
                  palette = c("#bcbddc", "#fa9fb5", "#abcdef"),
                  add = "boxplot", add.params = list(fill = "yellow")) +
  stat_compare_means(comparisons = comps) +
  stat_compare_means(label.y = 1.30)


# Plot 2: Violin plot with boxplot inside, customized p-value labels
plot2 <- ggviolin(data_PT, x = "temperature", y = "mumax", fill = "temperature",
                  palette = c("#bcbddc", "#fa9fb5", "#abcdef"),
                  add = "boxplot", add.params = list(fill = "yellow")) +
  stat_compare_means(comparisons = comps, label = "p.signif") + 
  stat_compare_means(label.y = 1.30)

# Combine the plots into a single frame
ggarrange(plot1, plot2, ncol = 2, nrow = 1,
          common.legend = TRUE, legend = "bottom")


data_PT$temperature <- factor(data_PT$temperature)
p_4 <- ggdensity(data_PT, x = "mumax",
          add = "mean", rug = TRUE,
          color = "temperature", fill = "temperature",
          palette = c("#feb24c", "#c51b8a", "#2b8cbe"))

data_PT$temperature <- factor(data_PT$temperature)
p_5 <- ggdensity(data_PT, x = "mumax",
          add = "mean", rug = TRUE,
          color = "temperature", fill = "temperature",
          palette = "jco")

p_6 <- gghistogram(data_PT, x = "mumax",
            add = "mean", rug = TRUE,
            color = "temperature", fill = "temperature",
            bins = 20,
            palette = c("#c994c7", "#fec44f", "#2c7fb8"))

p_7 <- gghistogram(data_PT, x = "mumax",
        add = "mean", rug = TRUE,
        color = "temperature", fill = "temperature",
        bins = 30,
        palette = c("#c994c7", "#fec44f", "#2c7fb8"))
