#
# Anna Underhill
# Cluster Color Components
# A program to analyze segmented images of grape clusters, using output from Food Color Inspector
#

setwd("WORKING DIRECTORY HERE")

## Import files:
my_files = list.files(pattern="*.csv") #Filenames from working directory  

my_data <- list()
for (i in 1:length(my_files)) {
  my_data[[i]] <- read.delim(my_files[i], sep=";", header = T, nrows = 6) #Clean data to include only RGB (or desired color space)
}                                                                         #nrows refers to class number

names(my_data) <- gsub("\\.csv$", "", my_files)

## Function to extract RGB data:
getClasses <- function(variable) { #Get 3 sets of RGB values for each image; change as desired
  red <- variable$R[3:5]
  green <- variable$G[3:5]
  blue <- variable$B[3:5]
  classes <- data.frame(red, green, blue)
}

for (i in 1:length(my_data)) {
  my_data[[i]] <- getClasses(my_data[[i]])  #Apply getClasses function to input data
}

## Change to data frame for grouping:
my_data_df = data.frame() #Preallocate data frame with same row names

for (i in 1:length(my_data)) {
  my_data_df[i,1] = geno_names[i]     
  my_data_df[i,2] = my_data[[i]][1,1] #Assign class 2 red
  my_data_df[i,3] = my_data[[i]][1,2] #Assign class 2 green
  my_data_df[i,4] = my_data[[i]][1,3] #Assign class 2 blue
  my_data_df[i,5] = my_data[[i]][2,1] #Assign class 3 red
  my_data_df[i,6] = my_data[[i]][2,2] #Assign class 3 green
  my_data_df[i,7] = my_data[[i]][2,3] #Assign class 3 blue
}

colnames(my_data_df) = c('geno_name','class2_red','class2_green','class2_blue','class3_red','class3_green','class3_blue')