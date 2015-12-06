require("ggplot2")
require("ggthemes")
require("gplots")
require("grid")
require("RCurl")
require("reshape2")
require("tableplot")
require("tidyr")
require("dplyr")
require("jsonlite")
require("extrafont")
require("lubridate")
boxplot <- dplyr::left_join(fast_food, zip_code, by="ZIP")
ggplot() +
  coord_cartesian() + 
  scale_x_discrete() +
  scale_y_continuous() +
  labs(title="Combined MPG of every model year") +
  labs(x="Year", y="Combined MPG") +
  layer(data=boxplot , 
        mapping=aes(x=RESTAURANT, y=MEDIAN),
        stat="identity",
        stat_params=list(), 
        geom="point",
        geom_params=list(color="red"), 
        position=position_identity()
  )+ 
  layer(data = boxplot,
        mapping=aes(x=RESTAURANT, y=MEDIAN),
        stat="boxplot",
        stat_params=list(),
        geom="boxplot",
        geom_params=list(color="black",fill="red", alpha=.4),
        posiion=position_identity()
  )+
  layer(data = boxplot,
          mapping=aes(x=RESTAURANT, y=MEDIAN),
          stat="boxplot",
          stat_params=list(),
          geom="errorbar",
          geom_params=list(color="black",fill="red", alpha=.4),
          posiion=position_identity()
  )
