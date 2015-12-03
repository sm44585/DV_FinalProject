require(jsonlite)
require(RCurl)

# The following is equivalent to create a crosstab with a KPIs in Tableau
KPI_LOW = .2   
KPI_HIGH = .4

#Join the fast food and fast food sales dataset
crosstab <- dplyr::inner_join(fast_food, fastfood_sale, by="RESTAURANT")
# The following is equivalent to creat a crosstab with two KPIs in Tableau"
crosstab <- crosstab %>%select(RESTAURANT, SALES, STATE)%>%group_by(STATE)%>%mutate(sum_total_sales = sum(as.numeric(SALES))) %>% group_by(STATE,RESTAURANT)%>% mutate(sum_restaurant_sales = sum(as.numeric(SALES))) %>% group_by(STATE, RESTAURANT) %>% summarise(sum_total_sales = mean(sum_total_sales), sum_restaurant_sales = mean(sum_restaurant_sales)) %>% mutate(ratio_1 = sum_restaurant_sales / sum_total_sales)%>% mutate(kpi_1 = ifelse(ratio_1 < KPI_LOW, '03 Low Market Share', ifelse(ratio_1 <= KPI_HIGH, '02 Average Market Share', '01 High Market Share')))

# This line turns the make and year columns into ordered factors.
crosstab <- crosstab %>% transform(STATE = ordered(STATE), RESTAURANT = ordered(RESTAURANT))

#This generates the crosstab plot
ggplot() +
  coord_cartesian() + 
  scale_x_discrete() +
  scale_y_discrete() +
  labs(title='Market Share of Fast Food Restaurants By State') +
  labs(x=paste("Fast Food Restaurant"), y=paste("State")) +
  layer(data=crosstab, 
        mapping=aes(x=RESTAURANT, y=STATE, label=round(ratio_1, 4)), 
        stat="identity", 
        stat_params=list(), 
        geom="text",
        geom_params=list(colour="black"), 
        position=position_identity()
  ) +
  layer(data=crosstab, 
        mapping=aes(x=RESTAURANT, y=STATE, fill=kpi_1), 
        stat="identity", 
        stat_params=list(), 
        geom="tile",
        geom_params=list(alpha=0.50), 
        position=position_identity()
  ) 
