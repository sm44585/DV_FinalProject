#ui.R 
require(shiny)
require(shinydashboard)
require(leaflet)

# Define UI for application that plots various distributions 
dashboardPage(
  dashboardHeader(title = "Final Project: U.S. Fast Food Sales and Zip Code Visualization", titleWidth = 600
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Market Share Crosstab", tabName = "mktShare_Crosstab", icon = icon("th")),
      menuItem("Bar Chart", tabName = "Bar_Chart", icon = icon("bar-chart")),
      menuItem("Boxplot", tabName = "Boxplot", icon = icon("th")),
      menuItem("Map", tabName = "Map", icon = icon("map-marker")),
      menuItem("Refresh All Plots and Data", tabName = "Refresh", icon = icon("database"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "mktShare_Crosstab",
              sliderInput("mktShare_KPILow", 
                          "Maximum Value for Low Market Share:", 
                          min = 0,
                          max = .25, 
                          value = .25),
              #Slider for PV2 KPI2
              sliderInput("mktShare_KPIHigh", 
                          "Maximum Value for Average Market Share:", 
                          min = .25, 
                          max = .5, 
                          value = .5),
              actionButton("Market_Share", "Generate Market Share Crosstab Plot"),
              plotOutput("crosstabPlot", width="100%", height=800)
      ),
    #bar chart tab  
    tabItem(tabName = "Bar_Chart",
            checkboxGroupInput(inputId = "RESTAURANT",
                                label ="Fast Food Restaurants:",
                                choices = c("All", "McDonalds", "Burger King","Pizza Hut","Taco Bell","Wendys","Jack in the Box", "Hardees", "Carls Jr", "In-N-Out","KFC"), selected = "McDonalds", inline = TRUE
            ),
            checkboxGroupInput(inputId = "STATE",
                               label ="States:",
                               choices = c("All", "AK", "AL","AR","AZ","CA","CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"), selected = "All", inline = TRUE
            ),
            #action button to generate bar chart plot
            actionButton("BarPlot", "Generate Bar Plot"),
            plotOutput("barchartPlot", width="auto", height=1200)
            ),
    #Boxplot tab        
    tabItem(tabName = "Boxplot",
            checkboxGroupInput(inputId = "BOX_RESTAURANT",
                               label ="Fast Food Restaurants:",
                               choices = c("All", "McDonalds", "Burger King","Pizza Hut","Taco Bell","Wendys","Jack in the Box", "Hardees", "Carls Jr", "In-N-Out","KFC"), selected = "All", inline = TRUE
            ),
            checkboxGroupInput(inputId = "BOX_STATE",
                               label ="States:",
                               choices = c("All", "AK", "AL","AR","AZ","CA","CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"), selected = "All", inline = TRUE
            ),
            #action button to generate box plot
            actionButton("BoxPlot", "Generate Box Plot"),
            plotOutput("BoxPlot", width="100%", height=800)
            ),
    tabItem(tabName = "Map",
            checkboxGroupInput(inputId = "MAP_RESTAURANT",
                               label ="Fast Food Restaurants:",
                               choices = c("All", "McDonalds", "Burger King","Pizza Hut","Taco Bell","Wendys","Jack in the Box", "Hardees", "Carls Jr", "In-N-Out","KFC"), selected = "All", inline = TRUE
            ),
            checkboxGroupInput(inputId = "MAP_STATE",
                               label ="States:",
                               choices = c("All", "AK", "AL","AR","AZ","CA","CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"), selected = "All", inline = TRUE
            ),
            #action button to generate map
            actionButton("Map", "Generate map"),
            leafletOutput("Map", width="100%", height = 600)
    ),
    tabItem(tabName = "Refresh",
            #action button to generate plots
            br(),br(),
            p("If you want to change inputs for multiple charts but don't want to push each button to update the chart, click the button below to refresh all of the plots at once."),
            actionButton("refreshAll", "Refresh All Plots"),
            br(),br(),
            p("If you want to refresh the data from Oracle, click the button below"),
            actionButton("refreshData", "Refresh the Data")
    )
    )
))
