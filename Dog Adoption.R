
# Setup -------------------------------------------------------------------

# Clear environment
rm(list = ls())

# Set wd
setwd("~/Data Science Projects/dog-adoption")

# Load libraries
library(rvest)
library(stringr)



# Web Scrape Dog Adoption Data --------------------------------------------

# Save Website URL
dogs <- read_html("http://www.labsandmore.org/dogs/?gender=&size=&breed=mix&category=")

# Identify number of dogs in database
dogcount <- dogs %>%
              html_nodes(xpath = "//*[@id='dogsearch']/p[2]/strong") %>%
              html_text() %>%
              as.numeric()

# Retreive Dog ID's
dog_id <- NULL
for (i in 1:dogcount) {
  dog_id[i] <-
    dogs %>%
      html_nodes(xpath = paste("//*[@id='dogsearch']/div[", i, "]/div/div[1]/div/ul/li[2]/a", sep = "")) %>%
      html_text() %>%
      str_sub(start = -4) %>%
      as.numeric()
}

# Create Dog Data Frame
dog_df <- data.frame(ID = dog_id)
for (i in 1:10) {
  dog_df[, i + 1] <- NA
}

# Retreive Dog Stats
for (i in 1:length(dog_id)) {
  dog <- read_html(paste("http://www.labsandmore.org/dog/?animalidnumber=", dog_id[i], sep = ""))
  breed <-
    dog %>%
    html_nodes(xpath = "//*[@id='details']/table") %>%
    html_table()
  breed <- t(breed[[1]])
  dog_df[dog_df$ID == dog_id[i], 2:11] <- breed[2, -11]
}

# Rename Columns
names(dog_df)[2:11] <- breed[1, -11]

# Establish Day Updated
dog_df$Updated <- Sys.Date()

# Save Data Frame
save(dog_df, file = "dog_df.RData")



