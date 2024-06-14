library(ggplot2)
library(vegan)
library(plyr)
library(broom)
install.packages("scatterplot3d")
library(scatterplot3d)

plot_dir = "/home/tri/Documents/microbiome/course/Basic_statistics/"

###~~~~~~~~~~~~~~~~~~~~Data in the nutshell~~~~~~~~~~~~~~~~~~~~###
dt.iris <- iris
head(dt.iris)
str(dt.iris)
summary(dt.iris)
boxplot(dt.iris)

## Histogram and Density plot
for (i in names(dt.iris[, 1:4])) {
  print(i)
  pdf(file=file.path(paste0(plot_dir, "Iris", i, ".pdf")))
  # Histogram
  hist(dt.iris [,i],
       col="peachpuff",
       border="black",
       prob = TRUE,
       xlab = i,
       main = "Penguin feature distribution")
  # Density
  lines(density(dt.iris[,i], na.rm=TRUE),
        lwd = 2,
        col = "chocolate")
  dev.off()
}

## Barplot
  pdf(file=file.path(paste0(plot_dir, "Iris",  ".pdf")))
  barplot(table(dt.iris[, 5]),
          border="white",
          col = c("darkorange", "purple", "cyan4"),
          main = names(dt.iris[, 5]))
  dev.off()


  pdf(file=file.path(paste0(plot_dir, "flower_pairs.pdf")))
  pairs(dt.iris)
  dev.off()
  
  pdf(file=file.path(paste0(plot_dir, "relationship.pdf")))
  boxplot(Sepal.Length ~ Species, dt.iris,
          col = c("darkorange", "purple", "cyan4"))
  boxplot(Sepal.Width ~ Species, dt.iris, 
          col = c("darkorange", "purple", "cyan4"))
  boxplot(Petal.Length ~ Species, dt.iris, 
          col = c("darkorange", "purple", "cyan4"))
  boxplot(Petal.Width ~ Species, dt.iris, 
          col = c("darkorange", "purple", "cyan4"))
  plot(Petal.Length ~ Petal.Width, dt.iris)
  dev.off()
  
  ###~~~~~~~~~~~~~~~~~~~~Descriptive statistic analysis~~~~~~~~~~~~~~~~~~~~###
  var_Petal_Length <- var(dt.iris$Petal.Length)
  var_Petal_Length
  table(is.na(dt.iris$Petal.Length))
  var_Petal_Length <- var(dt.iris$Petal.Length, na.rm=T)
  var_Petal_Length
  cat("Variance of Pental Length: ", var_Petal_Length, "\n")
  sd(dt.iris$Petal.Length, na.rm=T)
  sqrt(dt.iris$Petal.Length)
  
  tapply(dt.iris$Petal.Length, dt.iris$Species, function(x) {
    variances <- var(x, na.rm=T)
    return(variances)
  })
  
  ### Covariance
  ## Calculate
  
  mean(dt.iris$Sepal.Length)
  mean(dt.iris$Petal.Length)
  
  var_Petal_Width_Length <- var(dt.iris$Petal.Length,
                                dt.iris$Petal.Width,
                                na.rm=T)
  var_Petal_Width_Length
  
  table(is.na(dt.iris$Petal.Length), is.na( dt.iris$Petal.Width))
  
  cov_Petal_Width_Length <- cov(dt.iris$Petal.Length,
                                dt.iris$Petal.Width,
                                use="complete.obs")
  cov_Petal_Width_Length
  cat("Covariance of Petal.Length and Petal.Width: ",  cov_Petal_Width_Length, "\n")
  
  ## Scatter plot with covariance
  pdf(file=file.path(paste0(plot_dir, "cov.pdf")))
  plot(Petal.Length ~ Petal.Width, dt.iris)
  text(x=3200, y=225, labels=paste0("Cov = ", round(cov_mass_flipper,2)))
  dev.off()
  
  
  
  
  ###~~~~~~~~~~~~~~~~~~~~Is my data normal distribution?~~~~~~~~~~~~~~~~~~~~###
  
  pdf(file=file.path(paste0(plot_dir, "non-normality_Petal_Length.pdf")))
  ## Histogram
  hist(dt.iris$Petal.Length,
       col="peachpuff",
       border="black",
       prob = TRUE,
       xlab = "Petal.Length",
       main = "Non-normal distribution")
  lines(density(dt.iris$Petal.Length, na.rm=TRUE),
        lwd = 2,
        col = "chocolate")

  
  ## Q-Q plot
  qqnorm(dt.iris$Petal.Length, main='Non-normal distribution\nPetal.Length')
  qqline(dt.iris$Petal.Length)
  dev.off()
  
  ## Shapiro-Wilk Test
  shapiro.test(dt.iris$Petal.Length)
  
  
  ### Simulate Petal.Length from real one
  dt.iris$sim_Petal <- NA
  mean_Petal_Length <- mean(dt.iris$Petal.Length, na.rm=T)
  sd_Petal_Length <- sd(dt.iris$Petal.Length, na.rm=T)
  
  p_values_sw <- rep(0, 9)
  p_values_ks <- rep(0, 9)
  iteration <- 0
  
  while (any(p_values_sw < 0.8) | any(p_values_ks < 0.8)) {
    iteration <- iteration + 1
    cat(paste0("Number of iterations: ", iteration, "\n"))
    dt.iris$sim_Petal <- rnorm(nrow(dt.iris),
                         mean = mean_Petal_Length,
                         sd = sd_Petal_Length)
    
    p_values_sw <- sapply(c("setosa", "versicolor", "virginica"), function(y) {
        shapiro.test( dt.iris[!is.na(dt.iris$sim_Petal) & (dt.iris$Species == y), "sim_Petal"])$p.value
      })
    
    
    p_values_ks <- sapply(c("setosa", "versicolor", "virginica"), function(y) {
        ks.test(dt.iris[!is.na(dt.iris$sim_Petal) & ( dt.iris$Species == y), "sim_Petal"], "pnorm",
                mean = mean(dt.iris[dt.iris$Species == y, "sim_Petal"], na.rm = TRUE),
                sd = sd(dt.iris[dt.iris$Species == y, "sim_Petal"], na.rm = TRUE))$p.value
    })
  }
  cat(paste0("Reach condition at iterations: ", iteration, "\n"))
  
  ### Simulated body mass normality check
  pdf(file=file.path(paste0(plot_dir, "normality_Petal_Length.pdf")))
  ## Histogram
  hist(dt.iris$sim_Petal,
       col="peachpuff",
       border="black",
       prob = TRUE,
       xlab = "simulated Petal Length",
       main = "Normal distribution")
  lines(density(dt.iris$sim_Petal, na.rm=TRUE),
        lwd = 2,
        col = "chocolate")
  
  ## Q-Q plot
  qqnorm(dt.iris$sim_Petal, main='Normal distribution\nPetal.Length')
  qqline(dt.iris$sim_Petal)
  dev.off()
  
  ## Shapiro-Wilk Test
  shapiro.test(dt.iris$sim_Petal)
  
  
  
  
  ###~~~~~~~~~~~~~~~~~~~~Inferential statistics~~~~~~~~~~~~~~~~~~~~###
  ### Student t-test with microbiome dataset
  ## Two-sample Welch's t-test
  abund_table=read.csv("/home/tri/Documents/microbiome/course/Basic_statistics/VdrGenusCounts.csv",row.names=1,check.names=FALSE)
  str(abund_table)
  abund_table<-t(abund_table)
  
  grouping<-data.frame(row.names=rownames(abund_table),t(as.data.frame(strsplit(rownames(abund_table),"_"))))
  grouping$Location <- with(grouping, ifelse(X3%in%"drySt-28F", "Fecal", "Cecal"))
  grouping$Group <- with(grouping,ifelse(as.factor(X2)%in% c(11,12,13,14,15),c("Vdr-/-"), c("WT")))
  grouping <- grouping[,c(4,5)]
  grouping 
  table(grouping)
  
  library(vegan)
  
  H<-diversity(abund_table, "shannon") 
  
  df_H<-data.frame(sample=names(H),value=H,measure=rep("Shannon",length(H)))
  df_G <-cbind(df_H, grouping)
  rownames(df_G)<-NULL
  df_G
  
  Fecal_G<- subset(df_G, Location=="Fecal")
  Fecal_G
  
  library(ggplot2)
  
  p<-ggplot(Fecal_G, aes(x=value))+
    geom_histogram(color="black", fill="black")+
    facet_grid(Group ~ .)
  
  library(plyr)
  mu <- ddply(Fecal_G, "Group", summarise, grp.mean=mean(value))
  head(mu)
  
  p+geom_vline(data=mu, aes(xintercept=grp.mean, color="red"),
               linetype="dashed")
  
  fit_t <- t.test(value ~ Group, data=Fecal_G)
  fit_t
  
  
  ### Student t-test with iris dataset
  ## Split data
  dt.iris_species=dt.iris[(dt.iris$Species == "setosa") | (dt.iris$Species == "versicolor"), ]
  
  ## Syntax 
  ttest <- t.test(Sepal.Width ~ Species, data= dt.iris_species)
  ttest
  ttest$p.value
  ttest$statistic
  ttest$estimate
  
  ggplot(dt.iris_species, aes(x=Species, y=Sepal.Width, col=factor(Species))) + 
    geom_boxplot(notch=FALSE)
  
  
  
  ## One-way ANOVA with microbiome dataset
  library(vegan)
  CH=estimateR(abund_table)[2,] 
  df_CH <-data.frame(sample=names(CH),value=CH,measure=rep("Chao1",length(CH))) 
  df_CH_G <-cbind(df_CH, grouping)
  rownames(df_G)<-NULL
  df_CH_G
  
  df_CH_G$Group4<- with(df_CH_G, interaction(Location,Group))
  df_CH_G
  
  boxplot(value~Group4, data=df_CH_G, col=rainbow(4), main="Chao1 index")
  
  library(ggplot2)
  p <- ggplot(df_CH_G, aes(x=Group4, y=value),col=rainbow(4), main="Chao1 index") + 
    geom_boxplot()
  p + coord_flip()
  ggplot(df_CH_G, aes(x=Group4, y=value,col=factor(Group4))) + 
    geom_boxplot(notch=FALSE)
  
  library(dplyr)
  
  df_CH_G4 <- select(df_CH_G, Group4,value)
  df_CH_G4
  
  bartlett.test(value ~ Group4,  df_CH_G4)
  qchisq(0.95, 3)
  
  fligner.test(df_CH_G4, Group4)
  
  fit = lm(formula = value~Group4,data=df_CH_G)
  anova (fit)
  
  summary(aov(value~Group4, data=df_CH_G))
  
  aov_fit <- aov(value~Group4,data=df_CH_G) 
  summary(aov_fit, intercept=T) 
  
  qf(0.95, 12, 3)
  
  install.packages("mnormt")
  library(broom)
  
  tidy(aov_fit)
  augment(aov_fit)
  glance(aov_fit)
  
  ###~~~~~~~~~~~~~~~~~~~~Linear regression~~~~~~~~~~~~~~~~~~~~###
  ### Simple linear regression
  ## Perform
  model1 <- lm(Petal.Length ~ Petal.Width, dt.iris)
  model1
  summary(model1)
  
  ## Scatter with line plot
  pdf(file=file.path(paste0(plot_dir, "linear.pdf")))
  plot(Petal.Length ~ Petal.Width, dt.iris)
  abline(model1, lwd=2, col="red")
  dev.off()
  
  ### Multiple linear regression
  ## Perform
  model2 <- lm(Petal.Length ~Petal.Width + Sepal.Width, dt.iris)
  model2
  summary(model2)
  ## 3D  scatterplot
  scatter.3d <- with(dt.iris,
                     scatterplot3d( Petal.Width,
                                    Sepal.Width,
                                    Petal.Length,
                                    pch = 16,
                                    highlight.3d = TRUE,
                                    angle = 60)
  )
  scatter.3d$plane3d(model2)
  