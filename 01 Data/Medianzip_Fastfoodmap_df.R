require("jsonlite")
require("RCurl")

# Loads the data from Fast Food table into Fast Food dataframe
fast_food <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from FASTFOODMAPS_LOCATIONS_2007"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
#rename ZIP_CODE column to ZIP to match the zip code dataset
colnames(fast_food)[5] <- "ZIP"
summary(fast_food)

# Loads median, mean, and population data into Zip Code dataframe
zip_code <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from MedianZIP"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))

zip_code$MEAN <- as.numeric(levels(zip_code$MEAN))[zip_code$MEAN]
summary(zip_code)
