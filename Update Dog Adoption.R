
# Setup -------------------------------------------------------------------

# Clear environment
rm(list = ls())

# Set wd
setwd("~/Data Science Projects/dog-adoption")

# Load data
load("dog_df.RData")

# Load libraries
library(rvest)
library(stringr)



# Update Dog Adoption Data Frame ------------------------------------------

# Save Website URL
dogs <- read_html("http://www.labsandmore.org/dogs/?gender=&size=&breed=mix&category=")

# Identify number of dogs in database
dogcount <- dogs %>%
  html_nodes(xpath = "//*[@id='dogsearch']/p[2]/strong") %>%
  html_text() %>%
  as.numeric()

# Retreive New Dog ID's
dog_id <- NULL
for (i in 1:dogcount) {
  dog_id[i] <-
    dogs %>%
    html_nodes(xpath = paste("//*[@id='dogsearch']/div[", i, "]/div/div[1]/div/ul/li[2]/a", sep = "")) %>%
    html_text() %>%
    str_sub(start = -4) %>%
    as.numeric()
}
dog_id <- dog_id[!(dog_id %in% dog_df$ID)]

if (length(dog_id) != 0) {
  # Create Dog Data Frame
  new_dog_df <- data.frame(ID = dog_id)
  for (i in 1:10) {
    new_dog_df[, i + 1] <- NA
  }
  
  # Retreive Dog Stats
  for (i in 1:length(dog_id)) {
    dog <- read_html(paste("http://www.labsandmore.org/dog/?animalidnumber=", dog_id[i], sep = ""))
    breed <-
      dog %>%
      html_nodes(xpath = "//*[@id='details']/table") %>%
      html_table()
    breed <- t(breed[[1]])
    new_dog_df[new_dog_df$ID == dog_id[i], 2:11] <- breed[2, -11]
  }
  
  # Rename Columns
  names(new_dog_df)[2:11] <- breed[1, -11]
  
  # Establish Day Updated
  new_dog_df$Updated <- Sys.Date()
  
  # Merge New Data Frame
  dog_df <- cbind(dog_df, new_dog_df)
}

