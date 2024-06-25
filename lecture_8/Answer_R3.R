#Homework
#1.Use palmerpenguins” dataset 
install.packages("palmerpenguins")
library(palmerpenguins)
dim(penguins)
head(penguins)
# Remove NA in dataset
dt <- data.frame(na.omit(penguins))
dim(dt)
#a. Calculate the variance of "body_mass_g" 
#   and  use the tapply function to calculate the variance of "body_mass_g" by species.
var(dt$body_mass_g)

tapply(dt$body_mass_g, dt$species, var)
#b. Calculate the covariance and correlation between body_mass_g and flipper_length_mm.
cov(dt$body_mass_g, dt$flipper_length_mm)
cor(dt$body_mass_g, dt$flipper_length_mm)

#c. Check if the body mass of penguins is normally distributed (plot and statistic).
##Histogram and Q-Q plot
hist(dt$body_mass_g, col= "#fee8c8", prob=T, xlab= "Body mass", ylab= "Probability",
     main= "Non-normal distribution")
lines(density(dt$body_mass_g), col="red", lwd=2)

qqnorm(dt$body_mass_g, main="Q-Q Plot of Penguin Body Mass")
qqline(dt$body_mass_g)

### Check normality of body_mass_g using Shapiro-Wilk test
shapiro.test(dt$body_mass_g) #Non-normal distribution
### Check normality of body_mass_g using Kolmogorov-Smirnov Test
ks.test(dt$body_mass_g, "pnorm", mean=mean(dt$body_mass_g), sd=sd(dt$body_mass_g))

#e. Determine if there is any statistical difference in body mass between gender groups.
##Non-parametric, two group => Wilcoxon test
boxplot(dt$body_mass_g ~ dt$sex, col=c("#a6bddb", "#fdbb84"), xlab="Body mas", ylab="Gender")
wilcox.test(body_mass_g ~ sex, data=dt)

##Non-parametric, three or more groups => Kruskal-Wallis test
kruskal.test(body_mass_g ~ species, data=dt)

###2. Install packages “gcookbook”, open dataset “diamonds” in R and do as requested
library(gcookbook)
library(pastecs)
a=diamonds
a <- data.frame(na.omit(diamonds))
dim(a)
head(a)
##check if the depth and price of diamonds having Ideal cut and premium cut are normally distributed 
##(plot and statistic)
b=subset(a,cut=="Ideal",select = carat:price)
c=subset(a,cut=="Premium",select = carat:price)
d=subset(a,cut=="Fair",select = carat:price)
#Check normality of the price of Ideal cut diamonds 
#using plot, Shapiro-Wilk test and using Kolmogorov-Smirnov Test
hist(b$price, col="green", prob=T, xlab= "Price", ylab= "Frequency",
     main= "Distrubution of the price of Ideal cut diamonds")
lines(density(b$price), col="red", lwd=2)
qqnorm(b$price, main="Q-Q Plot of the price of Ideal cut diamonds")
qqline(b$price)
shapiro.test(b$price)
ks.test(b$price, "pnorm", mean=mean(b$price), sd=sd(b$price))
#Do the same to check normality of the depth of Ideal cut; price and depth of Premium cut

##Determine if there is any statistical difference in depth between Ideal and premium cut
##Non-parametric, two group => Wilcoxon test
boxplot(b$price,c$price,xlab="Diamond's cut",ylab="Price",names = c("Ideal","Premium"),main="Price of Ideal and Premium cut")
wilcox.test(b$price,c$price)

##Determine if there is any statistical difference in depth between Ideal, premium and Fair cut
boxplot(b$price,c$price,d$price,xlab="Diamond's cut",ylab="Price",names = c("Ideal","Premium","Fair"),main="Price of Ideal and Premium cut")
# Combine the price data into one numeric vector
all_prices <- c(b$price, c$price, d$price)
# Create a grouping factor
groups <- factor(c(rep("Ideal", length(b$price)),
                   rep("Premium", length(c$price)),
                   rep("Fair", length(d$price))))

# Perform the Kruskal-Wallis test
kruskal.test(all_prices ~ groups)

