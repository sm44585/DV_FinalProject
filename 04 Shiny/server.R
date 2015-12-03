# server.R
require(jsonlite)
require(RCurl)
require(ggplot2)
require(dplyr)
require(reshape2)
require(shiny)

shinyServer(function(input, output) {
  #Code to generate fast food locations data frame
  fast_food <- eventReactive(input$refreshData, {
    fast_food <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from FASTFOODMAPS_LOCATIONS_2007"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
  }, ignoreNULL = FALSE)
  
  #Code to generate the fast food sales locations data frame
  fast_food_sales <- eventReactive(input$refreshData, {
    fast_food_sales <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select RESTAURANT, SALES from FASTFOOD_SALES_RANK"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
  }, ignoreNULL = FALSE)
  
  #Code to generate the zip code data frame
  zip_code <- eventReactive(input$refreshData, {
    zip_code <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from MedianZIP"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
    zip_code$MEAN <- as.numeric(levels(zip_code$MEAN))[zip_code$MEAN]
  }, ignoreNULL = FALSE)
  
#   #Code that generates reactive transmission filter for the bar chart.
#   trans_filter <- eventReactive(c(input$refreshAll, input$BarPlot), {
#     if (input$TRANY == "All"){
#       trans_filter = c("Automatic 3-spd", "Automatic 4-spd","Automatic 5-spd","Automatic 6-spd","Automatic 6spd","Automatic 7-spd", "Automatic 8-spd", "Automatic 9-spd", "Manual 3-spd", "Manual 4-spd", "Manual 5-spd", "Manual 5 spd", "Manual 6-spd", "Manual 7-spd")
#     }
#     else {
#       trans_filter = input$TRANY
#     }
#     }, ignoreNULL = FALSE)
#   
#   #Code that generate reactive year selector for the scatter plot.
#   year_range <- eventReactive(c(input$refreshAll, input$ScatterPlot), {
#     if (input$BEG_YEAR <= input$END_YEAR){
#       year_range = input$BEG_YEAR:input$END_YEAR
#     }
#     else {
#       year_range = 1985:2016
#     }
#   }, ignoreNULL = FALSE)
  
  #Code that generates reactive KPI inputs for the Market Share crosstab
  KPI_LOW <- eventReactive(c(input$refreshAll,  input$Market_Share), {KPI_LOW = input$mktShare_KPILow }, ignoreNULL = FALSE)   
  KPI_HIGH <- eventReactive(c(input$refreshAll, input$Market_Share), {KPI_HIGH = input$mktShare_KPIHigh }, ignoreNULL = FALSE)
  
  #Code to generate PV2 Crosstab plot
  output$crosstabPlot <- renderPlot({
    #Join the fast food and fast food sales dataset
    crosstab <- dplyr::inner_join(fast_food(), fast_food_sales(), by="RESTAURANT")
    # The following is equivalent to creat a crosstab with two KPIs in Tableau"
    crosstab <- crosstab %>%select(RESTAURANT, SALES, STATE)%>%group_by(STATE)%>%mutate(sum_total_sales = sum(as.numeric(SALES))) %>% group_by(STATE,RESTAURANT)%>% mutate(sum_restaurant_sales = sum(as.numeric(SALES))) %>% group_by(STATE, RESTAURANT) %>% summarise(sum_total_sales = mean(sum_total_sales), sum_restaurant_sales = mean(sum_restaurant_sales)) %>% mutate(ratio_1 = sum_restaurant_sales / sum_total_sales)%>% mutate(kpi_1 = ifelse(ratio_1 < KPI_LOW(), '03 Low Market Share', ifelse(ratio_1 <= KPI_HIGH(), '02 Average Market Share', '01 High Market Share')))
    
    # This line turns the make and year columns into ordered factors.
    crosstab <- crosstab %>% transform(STATE = ordered(STATE), RESTAURANT = ordered(RESTAURANT))
    
    #This generates the PV4 with combined MPG plot
    plot <- ggplot() +
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
    # End your code here.
    return(plot)
  })
  
#   #Code to generate PV4 Crosstab plot
#   output$crosstabPV4Plot <- renderPlot({
#     crosstab <- vehicles() %>% group_by(MAKE, YEAR) %>% summarize(sum_comb08 = sum(COMB08), sum_pv2 = sum(PV2),sum_pv4 = sum(PV4)) %>% mutate(ratio_1 = sum_comb08 / (sum_pv2))%>% mutate(ratio_2 = sum_comb08 / (sum_pv4)) %>% mutate(kpi_1 = ifelse(ratio_1 < MPG_PV4_KPI_LOW(), '03 Not Efficient or Spacious', ifelse(ratio_1 <= MPG_PV4_KPI_HIGH(), '02 Average Efficiency and Space', '01 Efficient and Spacious')))%>% mutate(kpi_2 = ifelse(ratio_2 < MPG_PV4_KPI_LOW(), '03 Not Efficient or Spacious', ifelse(ratio_2 <= MPG_PV4_KPI_HIGH(), '02 Average Efficiency and Space', '01 Efficient and Spacious'))) %>%filter(MAKE %in% c("Acura", "Aston Martin", "Audi", "Bentley", "BMW", "Buick", "Chevrolet", "Dodge", "Ferrari", "Ford", "Honda", "Kia", "Lincoln", "Lexus", "Maserati", "Mazda", "Mercedes-Benz", "Nissan", "Toyota", "Volkswagen")) %>% filter(ratio_1 != Inf, ratio_2 != Inf)
#     
#     # This line turns the make and year columns into ordered factors.
#     crosstab <- crosstab %>% transform(MAKE = ordered(MAKE), YEAR = ordered(YEAR))
#     
#     #This generates the PV4 with combined MPG plot
#     plot <-ggplot() +
#       coord_cartesian() + 
#       scale_x_discrete() +
#       scale_y_discrete() +
#       labs(title='Vehicle Crosstab of Efficiency/Space ratio for 4 door cars') +
#       labs(x=paste("Make"), y=paste("Year")) +
#       layer(data=crosstab, 
#             mapping=aes(x=MAKE, y=YEAR, label=round(ratio_2, 2)), 
#             stat="identity", 
#             stat_params=list(), 
#             geom="text",
#             geom_params=list(colour="black"), 
#             position=position_identity()
#       ) +
#       layer(data=crosstab, 
#             mapping=aes(x=MAKE, y=YEAR, fill=kpi_2), 
#             stat="identity", 
#             stat_params=list(), 
#             geom="tile",
#             geom_params=list(alpha=0.50), 
#             position=position_identity()
#       ) 
#     # End your code here.
#     return(plot)
#   })
#   
#   #Code to generate Bar Chart Plot
#   output$barchartPlot <- renderPlot({
#     bar_chart <- vehicles() %>% select(TRANY, HIGHWAY08, CITY08) %>% subset(TRANY %in% trans_filter()) %>% group_by(TRANY) %>% summarise(avg_city_MPG = mean(CITY08), avg_highway_MPG = mean(HIGHWAY08)) %>% melt(id.vars = c("TRANY")) %>% group_by(variable) %>% mutate(WINDOW_AVG_MPG = mean(value))
#       #Plot Function to generate bar chart with reference line and values
#       plot <- ggplot() + 
#       coord_cartesian() + 
#       scale_x_discrete() +
#       scale_y_continuous() +
#       facet_wrap(~variable) +
#       labs(title='Average Highway and City MPG based on transmission ') +
#       labs(x=paste("Transmission"), y=paste("MPG")) +
#       layer(data=bar_chart, 
#             mapping=aes(x=TRANY, y=value), 
#             stat="identity", 
#             stat_params=list(), 
#             geom="bar",
#             geom_params=list(colour="blue", fill="white"), 
#             position=position_dodge()
#       ) + coord_flip() + 
#       layer(data=bar_chart, 
#             mapping=aes(x=TRANY, y=value, label=round(WINDOW_AVG_MPG, 2)), 
#             stat="identity", 
#             stat_params=list(), 
#             geom="text",
#             geom_params=list(colour="black", hjust=2), 
#             position=position_identity()
#       ) +
#       layer(data=bar_chart, 
#             mapping=aes(yintercept = WINDOW_AVG_MPG), 
#             geom="hline",
#             geom_params=list(colour="red")
#       ) +
#       layer(data=bar_chart, 
#             mapping=aes(x=TRANY, y=value, label=round(value, 2)), 
#             stat="identity", 
#             stat_params=list(), 
#             geom="text",
#             geom_params=list(colour="black", hjust=0), 
#             position=position_identity()
#       )
#     return(plot)
#   })
#   
#   #Code to generate the scatter plot
#   output$ScatterPlot <- renderPlot({
#     scatterplot <- vehicles() %>% select(COMB08, YEAR) %>% subset(YEAR %in% year_range()) %>% transform(YEAR = as.Date(as.character(YEAR), "%Y"))
#     plot <- ggplot() +
#       coord_cartesian() + 
#       scale_x_date() +
#       scale_y_continuous() +
#       labs(title="Combined MPG of every model year") +
#       labs(x="Year", y="Combined MPG") +
#       layer(data=scatterplot , 
#             mapping=aes(x=YEAR, y=COMB08),
#             stat="identity",
#             stat_params=list(), 
#             geom="point",
#             geom_params=list(), 
#             position=position_identity()
#       )
#     return(plot)
#   })
})
