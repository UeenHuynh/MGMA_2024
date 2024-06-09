###bt1:   

x1 = sample(70:100, 10, replace = TRUE)/100
y1 = sample(70:100, 10, replace = TRUE)/100

x2 = sample(0:50, 10)/100
y2 = sample(0:50, 10)/100

x <- c(x1, x2)
y <- c(y1, y2)

# Create an empty plot with the correct limits
plot(x, y, type = "n", main = 'Basic Scatter Plot', xlab = 'X', ylab = 'Y')

# Add the first set of points in red
points(x1, y1, pch = 19, cex = 2.5, col = 'red')

# Add the second set of points in blue
points(x2, y2, pch = 19, cex = 2.5, col = 'blue')

### bt2:
# mtcars = Motor Trend Car Road Tests
# check info of this data with "?mtcars"
df = mtcars

# trích xuất từ tabel các trường mpg, hp, wt
class(df)
subset <- df[c('mpg', 'hp', 'wt')]

# using box plot to display mpg fields.
boxplot(subset$hp, xlab='field', ylab='Gross horsepower', main='display hourse power', col='blue', horizontal=F)

# Display a histogram for the cyl field with appropriate labels and title using the hist() function.
hist(df$cyl, xlab="Cycle",main = "Distribution of Cycle", breaks=20)
#Display a bar graph for the cyl field with appropriate labels and title using the barplot() function
barplot(df$cyl,xlab="Cycle",main="Distribution of Cycle")

###bt3
# line graph
data("pressure")
# create a line graph between temperature and pressure
plot(pressure$temperature,  pressure$pressure,  type="l", xlab = "temperature", ylab = "pressure", main = "Temperature - Pressure")
# add points into the graph
points(pressure$temperature,pressure$pressure)
# add more lines and points into the graph
lines(pressure$temperature/2, pressure$pressure,col="red")
points(pressure$temperature/2,pressure$pressure,col="blue")
boxplot(pressure$temperature, xlab="Temperature", ylab="degree C",main="Distribution of Temperature",notch = T)



### bt4:
# Load the iris dataset
data(iris)

# Aggregate the data: mean Sepal.Length for each Petal.Width
aggregated_data <- aggregate(Sepal.Length ~ Species, data = iris, FUN = summary)
aggregated_data

# set color and label info
colors <- c('#a8ddb5', '#f8a4a7', '#f45d31')
species<- c('setosa', 'versicolor', 'virginica')

# Define the font size
font_size <- 2

barplot(height = aggregated_data$Sepal.Length, 
        names.arg = aggregated_data$Species, 
        xlab = "Petal Width", 
        ylab = "Mean Sepal Length", 
        main = "Mean Sepal Length by Petal Width",
        col=colors,
        cex.axis = font_size,
        cex.lab = font_size,
        cex.main = font_size + 1)
legend('topleft', species, box.lty=1, cex=2, fill=colors)

### bt5:
# Aggregate the data: mean Sepal.Length for each Species.
aggregated_data <- aggregate(Sepal.Length ~ Species, data = iris, FUN = summary)
aggregated_data

# check whether Sepal_Length in interquartile range (IQR) for each species.
within_range <- function(Sepal_Length, low, high){
    if (  Sepal_Length > low & Sepal_Length <= high ){
        return (TRUE)
    }
    return (FALSE)
}
# check Sepal_Length and set interquartile range (IQR) for each species.

Sepal_Length_within_standar_range  <- function(Sepal_Length, Species, aggregated_data){
    if (Species == 'setosa'){
        return (within_range(Sepal_Length, aggregated_data[aggregated_data$Species == 'setosa',2][2], aggregated_data[aggregated_data$Species == 'setosa',2][5] ))
    }else if (Species == 'versicolor'){
        return (within_range(Sepal_Length,  aggregated_data[aggregated_data$Species == 'versicolor',2][2], aggregated_data[aggregated_data$Species == 'versicolor',2][5]))
    }
    return (within_range(Sepal_Length, aggregated_data[aggregated_data$Species == 'virginica',2][2], aggregated_data[aggregated_data$Species == 'virginica',2][5]))
}

index4 <- mapply(FUN=Sepal_Length_within_standar_range , Sepal_Length=iris$Sepal.Length, Species=iris$Species,MoreArgs = list(aggregated_data = aggregated_data))
index4
# set colors and label info.

colors <- c('#a8ddb5', '#f8a4a7', '#f45d31')
species<- c('setosa', 'versicolor', 'virginica')
# display histogram.

iris[index4,]$Sepal.Length
hist(iris[index4,]$Sepal.Length, 
     xlab = "Sepal Length", ylab = "Frequency", 
     main = "Histogram of Sepal Length",
     col=colors)

legend('topleft', species, box.lty=1, cex=2, fill=colors)

