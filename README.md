# DV_FinalProject
Dr. Cannata Final Project
Patricia O'Brien, Chenchao Zang, Spencer Muncey

##Datasets

1. Fastfood_map dataset from [fast food maps](http://www.fastfoodmaps.com)
2. Median_ZipCode dataset from [American Community Survey](http://www.psc.isr.umich.edu/dis/census/Features/tract2zip/)
3. [Average revenue per Fast Food franchise](https://www.qsrmagazine.com/reports/top-50-sorted-rank)

Main idea behind our project is to look at these three datasets to find trends and produce interesting visualizations. All visualizations have to be produced in R/SQL, Tableau, and used in a Shiny application.

##6 Total Plots

1. Crosstab with KPI
    + KPI is Total Revenue for one Restaurant divided by Total Revenues of all fast food restaurants in a zip code
2. Wealth of Zip Code (using Median Salary) for each restaruant using facet wrap in R and Pages in Tableau
    + Y axis is total restaruants in a zip code for a particular brand
    + X axis is median salary for that zip code
3. Relationship of zip code population and # of fast food restaurants [Plot 3 of Project 3](https://github.com/sm44585/DV_RProject3/blob/master/02%20Data%20Wrangling/Project3_Plot3.R)
4. Map showing KPI of restaruants per capita [look at page 27 of Cannata's presentation](http://www.cs.utexas.edu/~cannata/dataVis/Class%20Notes/_05%20Tableau%20Overview/Tableau%20Overview.pdf)
    + Total number of restaurants divided by Total population of the state
    + Get the population of the state by aggregating the zip code (group by)
5. Scatterplot looking at if Population of Zip Code affects Total Sales Revenue of all Restaurants
    + X axis - Population of Zip Code
    + Y axis - Estimated Sales Revenue of all restaurants in zip code (may be able to facet wrap by brand if we have time and not too difficult)
6. Bar chart that looks at the estimated sales revenue of each restaurant by state
    + Columns: Estimated Sales Revenue
    + Rows: States, Brand of Fast Food
    + Average per state (Average Trend line per Tableau Pane)

##Chenchao
Plot 3 and Plot 6

##Patricia
Plot 4 and Plot 5

##Spencer
Plot 1 and Plot 2
