## Install packages

#Install DESeq2
if (!require("BiocManager", quietly = TRUE))
        install.packages("BiocManager")

BiocManager::install("DESeq2")

install.packages("ggplot2") #Install ggplot2

BiocManager::install("EnhancedVolcano") #Install EnhancedVolcano



## Load packages
library(DESeq2)
library(EnhancedVolcano)
library(ggplot2)




#Load a .RData file named "otu_data"
#The object will be loaded into the environment with its original name
load("C:/Users/KhaiNguyen/OneDrive/Documents/deseq2_practice/otu_data") 

#Create a object named "counts.data"
counts.data <- otu_data

#Check 
ncol(counts.data)
head(counts.data) 





#Load a .RData file named "smd"
#The object will be loaded into the environment with its original name
load("C:/Users/KhaiNguyen/OneDrive/Documents/deseq2_practice/smd") 

#Create a object named "meta.data"
meta.data <- smd

#Check 
nrow(meta.data)
head(meta.data)





#Making sure the row names in meta.data matches to column names in counts.data**
all(colnames(counts.data) %in% rownames(meta.data))

#Are they in the same order?
all(colnames(counts.data) == rownames(meta.data))





# Construct a DESeqDataSet object with DESeqDataSetFromMatrix() function in DESeq2
dds <- DESeqDataSetFromMatrix(countData = counts.data,
                              colData = meta.data,
                              design = ~ health_status)
dds #Show results





# keeping OTU that have at least 10 reads total
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

dds





# Run DESeq2
dds <- DESeq(dds) 

#Set threshold for adjusted P value < 0.05, and |log2FoldChange| > 1 
res <- results(dds, alpha = 0.05, lfcThreshold = 1) 
res




#Compare 2 to 3 
res2_3 <- results(dds, contrast = c("health_status", "2", "3")) 

res2_3




### Explore Results
summary(res)




### Visualization

#MA plot by plotMA() function in DESeq2:
plotMA(res)



# Create EnhancedVolcano plot
EnhancedVolcano(res,
                lab = rownames(res),
                title = 'Volcano plot',            # Title of the plot
                subtitle = 'log2FoldChange cutoff: ±1, adjusted P-value cutoff: 0.05', # Subtitle of the plot
                x = 'log2FoldChange',
                y = 'padj',
                xlim = c(min(res$log2FoldChange), 2),
                ylim = c(0, -log10(10e-10)),
                xlab = 'log2FoldChange',
                ylab= '-Log10(adjusted P-value)',
                axisLabSize = 13,
                pCutoff = 0.05,
                FCcutoff = 1.0,
                pointSize = 1.5,
                legendLabels = c('Non-significant', 'Log2FC', 'Adjusted P-value', 'Adjusted P-value & Log2FC'),
                caption = 'health_status_3 to health_status_1',
                captionLabSize = 18,
                legendPosition = 'top', # Position of the legend  # Only label the selected points
                boxedLabels = TRUE,   
                drawConnectors = TRUE)  # Optional: Connect labels with lines





### Manual test


#'dds' is your DESeqDataSet and 'res' is the DESeq2 results object

# Convert DESeq2 results to a data frame
res_df <- as.data.frame(res)

# Filter results based on padj < 0.05 and log2FoldChange > 1
filtered_res <- res_df[res_df$padj < 0.05 & abs(res_df$log2FoldChange) > 1, ]

# Extract raw counts
count_data <- counts(dds)

# Extract condition information
colData_dds <- colData(dds)
condition1_samples <- colData_dds$health_status == "1"
condition3_samples <- colData_dds$health_status == "3"

# Prepare a data frame to store p-values and group labels
plot_data <- data.frame()

# Perform t-test for each gene and collect p-values
for (gene in rownames(filtered_res)) {
        if (gene %in% rownames(count_data)) {
                counts_gene <- count_data[gene, ]
                t_test <- t.test(counts_gene[condition3_samples], counts_gene[condition1_samples])
                
                # Append results to plot_data
                plot_data <- rbind(plot_data, data.frame(
                        Gene = gene,
                        PValue = t_test$p.value,
                        Group = rep(c("3", "1"), each = length(c(condition3_samples, condition1_samples)))
                ))
        }
}

# Create the boxplot
ggplot(plot_data, aes(x = PValue, y = Group)) +
        geom_boxplot() +
        labs(x = "P-value from T-test", y = "health_status", title = "Boxplot of T-test P-values Comparing feature's raw count of health_status_3 to health_status_1's") +
        scale_x_continuous(labels = scales::comma_format()) +
        theme_minimal()



