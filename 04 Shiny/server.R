# server.R
require(jsonlite)
require(RCurl)
require(ggplot2)
require(dplyr)
require(reshape2)
require(shiny) 
require(scales)

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
  }, ignoreNULL = FALSE)
  
  #Code that generates reactive restaurant filter for the bar chart.
  filter_restaurant <- eventReactive(c(input$refreshAll, input$BarPlot), {
    if (input$RESTAURANT == "All"){
      filter_restaurant = c("McDonalds", "Burger King","Pizza Hut","Taco Bell","Wendys","Jack in the Box", "Hardees", "Carls Jr", "In-N-Out","KFC")
    }
    else {
      filter_restaurant = input$RESTAURANT
    }
    }, ignoreNULL = FALSE)
  
  #Code that generates reactive state filter for the bar chart.
  filter_state <- eventReactive(c(input$refreshAll, input$BarPlot), {
    if (input$STATE == "All"){
      filter_state = c("AK", "AL","AR","AZ","CA","CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY")
    }
    else {
      filter_state = input$STATE
    }
  }, ignoreNULL = FALSE)
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
  
  #Code to generate Bar Chart Plot
  output$barchartPlot <- renderPlot({
    join_data<-dplyr::inner_join(fast_food(), fast_food_sales(), by="RESTAURANT")
    bar_chart <- join_data %>% select(STATE, RESTAURANT, SALES) %>% subset(STATE%in% filter_state())%>%subset(RESTAURANT%in% filter_restaurant())%>%group_by(STATE,RESTAURANT) %>% summarise(sum_sales = sum(as.numeric(SALES)))%>%melt(id.vars = c("STATE","RESTAURANT"))%>%group_by(variable)%>%group_by(STATE)%>%group_by(STATE)
    WINDOW_AVG=aggregate(bar_chart[, 4], list(RESTAURANT=bar_chart$RESTAURANT), mean)
    bar_chart<-dplyr::right_join(bar_chart, WINDOW_AVG, by="RESTAURANT")
    bar_chart<-bar_chart %>% select (STATE,RESTAURANT,variable,value.x,value.y)%>%mutate(Diff_To_Avg = value.x - value.y)
    options(scipen = 999)
      #Plot Function to generate bar chart with reference line and values
      plot <- ggplot() + 
        coord_cartesian() + 
        scale_x_discrete() +
        scale_y_continuous(labels = dollar) +
        facet_wrap(~RESTAURANT) +
        labs(title='Total sales of every fastfood restaurant in every state ') +
        labs(x=paste("State"), y=paste("Sales")) +
        layer(data=bar_chart, 
              mapping=aes(x=STATE, y=value.x), 
              stat="identity", 
              stat_params=list(), 
              geom="bar",
              geom_params=list(fill="steelblue"), 
              position=position_dodge()
        )+ coord_flip()+  
        layer(data=bar_chart, 
              mapping=aes(x=STATE, y=value.x, label=round(value.x,2),size=value.x),
              stat="identity", 
              stat_params=list(), 
              geom="text",
              geom_params=list(colour="black", hjust=0), 
              position=position_identity()
        )+
        layer(data=bar_chart, 
              mapping=aes(yintercept = value.y), 
              geom="hline",
              linetype="dashed",
              size=2,
              geom_params=list(colour="red")
        )+
        layer(data=bar_chart, 
              mapping=aes(x=STATE, y=value.x, label=round(Diff_To_Avg)), 
              stat="identity", 
              stat_params=list(), 
              geom="text",
              geom_params=list(colour="red", hjust=-2), 
              position=position_identity()
        )
    return(plot)
  })
  
  #Code to generate the scatter plot
  output$BoxPlot <- renderPlot({
    #boxplot <- dplyr::left_join(fast_food(), fast_food_sales(), by="RESTAURANT", copy = TRUE)
    boxplot <- dplyr::left_join(fast_food(), zip_code(), by="ZIP")
    #colnames(boxplot)[5] <- "ZIP"
    #boxplot <- dplyr::left_join(boxplot, zip_code(), by = "ZIP", copy = TRUE)
    #boxplot <- boxplot %>% subset(RESTAURANT %in% filter_restaurant()) %>% subset(STATE %in% filter_state()) 
    plot <- ggplot() +
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_continuous() +
      labs(title="Combined MPG of every model year") +
      labs(x="Year", y="Combined MPG") +
      layer(data=boxplot, 
            mapping=aes(x=RESTAURANT, y=MEDIAN),
            stat="identity",
            stat_params=list(), 
            geom="point",
            geom_params=list(), 
            position=position_identity()
      )+
      layer(data = boxplot,
            mapping=aes(x=RESTAURANT, y=MEDIAN),
            stat="boxplot",
            stat_params=list(),
            geom="boxplot",
            geom_params=list(color="black",fill="red", alpha=.4),
            posiion=position_identity()
      )
    return(plot)
  })
})
