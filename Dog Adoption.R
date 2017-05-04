library(rvest)
library(stringr)

dogs <- read_html("http://www.labsandmore.org/dogs/?gender=&size=&breed=mix&category=")



dogcount <- dogs %>%
              html_nodes(xpath = "//*[@id='dogsearch']/p[2]/strong") %>%
              html_text() %>%
              as.numeric()

df <- data.frame(ID = NA)

for (i in 1:dogcount) {
  df[i, "ID"] <-
    dogs %>%
      html_nodes(xpath = paste("//*[@id='dogsearch']/div[", i, "]/div/div[1]/div/ul/li[2]/a", sep = "")) %>%
      html_text() %>%
      str_sub(start = -4) %>%
      as.numeric()
}

for (i in 58:nrow(df)) {
  dog <- read_html(paste("http://www.labsandmore.org/dog/?animalidnumber=", df[i, "ID"], sep = ""))
  breed <-
    dog %>%
    html_nodes("td") %>%
    html_text()
  df[i, "Breed"] <- breed[2]
}

//*[@id="details"]/table

for (i in 1:nrow(df)) {
  dog <- read_html(paste("http://www.labsandmore.org/dog/?animalidnumber=", df[i, "ID"], sep = ""))
  breed <-
    dog %>%
    html_nodes(xpath = "//*[@id='details']/table") %>%
    html_table()
  breed <- t(breed[[1]])
}

df2 <- data.frame(matrix(NA, ncol = 11))
