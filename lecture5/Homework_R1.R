# Exercise R1
data <- iris
dim(iris) # This will show the number of rows and columns
head(iris)

# Find minimum values of the four features
min_values <- apply(data[, 1:4], 2, min)

# Find maximum values of the four features
max_values <- apply(data[, 1:4], 2, max)

# Calculate the mean of each feature for each species
mean_sepal_length <- tapply(data$Sepal.Length, data$Species, mean)

mean_sepal_width <- tapply(data$Sepal.Width, data$Species, mean)

mean_petal_length <- tapply(data$Petal.Length, data$Species, mean)

mean_petal_width <- tapply(data$Petal.Width, data$Species, mean)

# If-else function to compare the average sepal lengths
mean_sepal_length[1]
mean_sepal_length[2]

if (mean_sepal_length[1] > mean_sepal_length[2]) {
  print("The sepal length of setosa is greater than versicolor")
} else if (mean_sepal_length[1]  < mean_sepal_length[2]) {
  print("The sepal length of setosa is less than versicolor")
} else {
  print("The sepal length of setosa is equal to versicolor")
}

# For loop with nested if-else to print rows based on conditions
for (i in 1:nrow(data)) {
  if (data$Petal.Width[i] == 0.2 && data$Species[i] == "setosa") {
    print(data[i,])
  }
}

# Create a new column 'classification' in the data
data$classification <- NA

# Assign classifications based on conditions
for (i in 1:nrow(data)) {
  if (data$Sepal.Length[i] < avg_sepal_length && data$Sepal.Width[i] < avg_sepal_width) {
    data$classification[i] <- "Small"
  } else if (data$Sepal.Length[i] >= avg_sepal_length && data$Sepal.Width[i] >= avg_sepal_width) {
    data$classification[i] <- "Large"
  } else {
    data$classification[i] <- "Medium"
  }
}

# Display the first few rows of the updated data
head(data)



