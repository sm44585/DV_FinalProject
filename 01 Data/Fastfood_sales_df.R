require("jsonlite")
require("RCurl")

# Loads the data from Total Car Sales table into CAR_Sale dataframe
# Change the USER and PASS below to be your UTEid
FASTFOOD_SALE <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select COMPANY, SALES from FASTFOOD_SALES_RANK"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE),))

summary(FASTFOOD_SALE)