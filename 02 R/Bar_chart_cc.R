require("jsonlite")
require("RCurl")
require(dplyr)
require(tidyr)
require(ggplot2)
require(reshape2)
library(scales)

fast_food <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from FASTFOODMAPS_LOCATIONS_2007"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE),))
#View(fast_food)

FASTFOOD_SALE <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from FASTFOOD_SALES_RANK"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cz4795', PASS='orcl_cz4795', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
#View(FASTFOOD_SALE)

join_data<-dplyr::inner_join(fast_food, FASTFOOD_SALE, by="RESTAURANT") 

bar_chart <- join_data %>% select(STATE, RESTAURANT, SALES) %>% subset(STATE%in% c("AK", "AL","AR","AZ","CA","CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"))%>%subset(RESTAURANT%in% c("McDonalds", "Burger King"))%>%group_by(STATE,RESTAURANT) %>% summarise(sum_sales = sum(as.numeric(SALES)))%>%melt(id.vars = c("STATE","RESTAURANT"))%>%group_by(variable)%>%group_by(STATE)%>%group_by(STATE)
#%>%mutate(WINDOW_AVG_MPG = mean(value))

#WINDOW_AVG=aggregate(bar_chart[, 4], list(STATE=bar_chart$STATE), mean)
WINDOW_AVG=aggregate(bar_chart[, 4], list(RESTAURANT=bar_chart$RESTAURANT), mean)
#bar_chart<-dplyr::right_join(bar_chart, WINDOW_AVG, by="STATE") 
bar_chart<-dplyr::right_join(bar_chart, WINDOW_AVG, by="RESTAURANT")

bar_chart<-bar_chart %>% select (STATE,RESTAURANT,variable,value.x,value.y)%>%mutate(Diff_To_Avg = value.x - value.y)
#Plot Function to generate bar chart with reference line and values
ggplot(data=bar_chart, aes(x=STATE, y=value.x)) +
  geom_bar(stat="identity", fill="steelblue")+
  facet_wrap(~RESTAURANT)+
  labs(x=paste("State"), y=paste("Sales"))+
  geom_text(aes(label=value.x, size=value.x), vjust=0, color="BLACK")+
  scale_size(range=c(3,6)) +
  scale_y_continuous(labels = dollar)+
  geom_hline(yintercept=value.y, linetype="dashed", 
             color = "red", size=2)+
  coord_flip()+
  theme_bw()+
  theme_minimal()+
  #geom_hline(yintercept=value.y, linetype="dashed", 
             color = "red", size=2)

+
  layer(data=bar_chart, 
        mapping=aes(yintercept = value.y), 
        geom="hline",
        linetype="dashed",
        size=2,
        geom_params=list(colour="red")
  )+
  layer(data=bar_chart, 
        mapping=aes(x=STATE, y=value.x, label=round(Diff_To_Avg, 2)), 
        stat="identity", 
        stat_params=list(), 
        geom="text",
        geom_params=list(colour="black", hjust=-3), 
        position=position_identity()
  )
#"Pizza Hut","Taco Bell","Wendys","Jack in the Box", "Hardees", "Carls Jr", "In-N-Out","KFC"
ggplot() + 
  coord_cartesian() + 
  scale_x_discrete() +
  scale_y_continuous() +
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











+
  layer(data=bar_chart, 
        mapping=aes(x=STATE, y=value.x, yintercept = value.y, label=round(value.y)), 
        stat="identity",
        #stat_params=list(),
        geom="text",
        geom_params=list(colour="black", hjust=0)
  )





