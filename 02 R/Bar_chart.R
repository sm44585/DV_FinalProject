require("jsonlite")
require("RCurl")
require(dplyr)
require(tidyr)
require(ggplot2)
require(reshape2)

fast_food <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from FASTFOODMAPS_LOCATIONS_2007"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE),))
#View(fast_food)

FASTFOOD_SALE <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from FASTFOOD_SALES_RANK"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE),))
#View(FASTFOOD_SALE)

join_data<-dplyr::inner_join(fast_food, FASTFOOD_SALE, by="RESTAURANT") 

bar_chart <- join_data %>% select(STATE, RESTAURANT, SALES) %>% subset(STATE%in% c("AK", "AL","AR","AZ","CA","CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"))%>%subset(RESTAURANT%in% c("McDonalds", "Burger King","Pizza Hut","Taco Bell","Wendys","Jack in the Box", "Hardees", "Carls Jr", "In-N-Out","KFC"))%>%group_by(STATE,RESTAURANT) %>% summarise(sum_sales = sum(as.numeric(SALES)))%>%melt(id.vars = c("STATE","RESTAURANT"))%>%group_by(variable)%>%group_by(STATE)%>%group_by(STATE)
WINDOW_AVG=aggregate(bar_chart[, 4], list(STATE=bar_chart$STATE), mean)
bar_chart<-dplyr::inner_join(bar_chart, WINDOW_AVG, by="STATE") 
#Plot Function to generate bar chart with reference line and values
ggplot() + 
  coord_cartesian() + 
  scale_x_discrete() +
  scale_y_continuous() +
  facet_wrap(~variable) +
  labs(title='Total sales of every fastfood restaurant in every state ') +
  labs(x=paste("State"), y=paste("Sales")) +
  layer(data=bar_chart, 
        mapping=aes(x=STATE, y=value.x), 
        stat="identity", 
        stat_params=list(), 
        geom="bar",
        geom_params=list(colour="blue", fill="white"), 
        position=position_dodge()
  ) + coord_flip() + 
  layer(data=bar_chart, 
        mapping=aes(x=STATE, y=value.x, label=round(value.x, 2)), 
        stat="identity", 
        stat_params=list(), 
        geom="text",
        geom_params=list(colour="black", hjust=2), 
        position=position_identity()
  ) +
  layer(data=bar_chart, 
        mapping=aes(yintercept = value.y), 
        geom="hline",
        geom_params=list(colour="red")
  ) +
  layer(data=bar_chart, 
        mapping=aes(x=STATE, y=value.x, label=round(value.y, 2)), 
        stat="identity", 
        stat_params=list(), 
        geom="text",
        geom_params=list(colour="black", hjust=0), 
        position=position_identity()
  )
