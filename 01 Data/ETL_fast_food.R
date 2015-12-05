#Before running this R file make sure you set you working directory to where the CSV file located.

file_path <- "fastfoodmaps_locations_2007.csv"

df <- read.csv(file_path, stringsAsFactors = FALSE)

# Replace "." (i.e., period) with "_" in the column names.
names(df) <- gsub("\\.+", "_", names(df))

str(df) # Uncomment this and  run just the lines to here to get column types to use for getting the list of measures.

# Generate List of Measures
measures <- c("ZIP", "Row_Num", "LAT", "LONGI")


# Make Zip codes all five digits
df$ZIP <- gsub(df$ZIP, pattern="-.*", replacement = "")
# remove leading zero on zip codes to match other data set
df$ZIP <- gsub(df$ZIP, pattern="^0", replacement = "")

#Relabel the restaurant columns
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^m", replacement = "McDonalds")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^b", replacement = "Burger King")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^p", replacement = "Pizza Hut")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^t", replacement = "Taco Bell")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^w", replacement = "Wendys")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^j", replacement = "Jack in the Box")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^h", replacement = "Hardees")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^c", replacement = "Carls Jr")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^i", replacement = "In-N-Out")
df$RESTAURANT <- gsub(df$RESTAURANT, pattern="^k", replacement = "KFC")

# Get rid of special characters in each column.
# Google ASCII Table to understand the following:
for(n in names(df)) {
  df[n] <- data.frame(lapply(df[n], gsub, pattern="[^ -~]",replacement= ""))
}

dimensions <- setdiff(names(df), measures)

#dimensions
if( length(measures) > 1 || ! is.na(dimensions)) {
  for(d in dimensions) {
    # Get rid of " and ' in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern="[\"']",replacement= ""))
    # Change & to and in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern="&",replacement= " and "))
    # Change : to ; in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern=":",replacement= ";"))
  }
}


# Get rid of all characters in measures except for numbers, the - sign, and period.dimensions
if( length(measures) > 1 || ! is.na(measures)) {
  for(m in measures) {
    df[m] <- data.frame(lapply(df[m], gsub, pattern="[^--.0-9]",replacement= ""))
  }
}

write.csv(df, paste(gsub(".csv", "", file_path), ".reformatted.csv", sep=""), row.names=FALSE, na = "")

tableName <- gsub(" +", "_", gsub("[^A-z, 0-9, ]", "", gsub(".csv", "", file_path)))
sql <- paste("CREATE TABLE", tableName, "(\n-- Change table_name to the table name you want.\n")
if( length(measures) > 1 || ! is.na(dimensions)) {
  for(d in dimensions) {
    sql <- paste(sql, paste(d, "varchar2(4000),\n"))
  }
}
if( length(measures) > 1 || ! is.na(measures)) {
  for(m in measures) {
    if(m != tail(measures, n=1)) sql <- paste(sql, paste(m, "number(38,4),\n"))
    else sql <- paste(sql, paste(m, "number(38,4)\n"))
  }
}
sql <- paste(sql, ");")
cat(sql)
