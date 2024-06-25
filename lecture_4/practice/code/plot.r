# Import library
library(ggplot2)
library(tidyverse)
library(readr)
library(ggforce)
library(ggbreak)

# Import data
nread <- read_tsv("/mnt/portable_drive/microbiome/out/n_read_per_sample.tsv", 
                col_names = FALSE)

# Plot
nread |>
    mutate(n_reads = ifelse(X2>7000, ">7000", "<7000")) |>
    arrange(X2) |>
    ggplot(aes(x=fct_inorder(factor(X1)), y=X2, fill=n_reads)) + 
    geom_col() +
    scale_fill_manual(values = c("red", "grey")) +
    scale_y_continuous(breaks=seq(0, 100000, 20000), limits=c(0,50000)) +
    theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
    labs(
        x = "Sample",
        y = "Number of reads",
        title = "Number of reads per sample"
    ) + geom_vline(aes(xintercept=X1), data=. %>% filter(X2 > 7000 & X2 < 7300), linetype="dashed")
# Save data
ggsave("test.png", units = "px", width = 1500, height = 1000)
