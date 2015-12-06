require("jsonlite")
require("RCurl")
require(dplyr)
require(tidyr)
require(ggplot2)
require(reshape2)
library(scales)
#Join fast food locations and fast food sales by franchise unit datasets
join_data<-dplyr::inner_join(fast_food, fast_food_sale, by="RESTAURANT") 

#R workflow to generate the bar chart
bar_chart <- join_data %>% select(STATE, RESTAURANT, SALES) %>% subset(STATE%in% c("AK", "AL","AR","AZ","CA","CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"))%>%subset(RESTAURANT%in% c("McDonalds", "Burger King"))%>%group_by(STATE,RESTAURANT) %>% summarise(sum_sales = sum(as.numeric(SALES)))%>%melt(id.vars = c("STATE","RESTAURANT"))%>%group_by(variable)%>%group_by(STATE)%>%group_by(STATE)

#Generate window average 
WINDOW_AVG=aggregate(bar_chart[, 4], list(RESTAURANT=bar_chart$RESTAURANT), mean)

bar_chart<-dplyr::right_join(bar_chart, WINDOW_AVG, by="RESTAURANT")

bar_chart<-bar_chart %>% select (STATE,RESTAURANT,variable,value.x,value.y)%>%mutate(Diff_To_Avg = value.x - value.y)
options(scipen = 999)
#Plot Function to generate bar chart with reference line and values
ggplot() + 
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
        mapping=aes(x=STATE, y=value.x, label=round(value.x,2)),
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
