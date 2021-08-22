#user-interface definition of a Shiny web application. 
library(shiny)
library(shinydashboard)

####control time-out

tags$head(
        HTML(
          "
          <script>
          var socket_timeout_interval
          var n = 0
          $(document).on('shiny:connected', function(event) {
          socket_timeout_interval = setInterval(function(){
          Shiny.onInputChange('count', n++)
          }, 15000)
          });
          $(document).on('shiny:disconnected', function(event) {
          clearInterval(socket_timeout_interval)
          });
          </script>
          "
        )
        )

 dashboardPage(
    dashboardHeader(title = "US Presidential Election Profile",
                     # dropdownMenu(badgeStatus = "success", type = c("messages","notifications","tasks"),
                     #              messageItem("EC",
                     #                          "We are here to view the election history", 
                     #                          icon = shiny::icon("user"), 
                     #                          time = "Today"),
                     #              notificationItem(icon = icon("users"), status = "info", "Get ready!"),
                     #              taskItem(value = 50, color = "green", "Check the task")),
                    
                    dropdownMenu(badgeStatus = "warning", type = "notifications", icon = icon("bells"), 
                                 headerText = "Take note",
                                 notificationItem("Sometime presidential candidates lose popular votes but gets to be president",
                                                  icon = icon("info-circle"), status = "danger"))),
    
    dashboardSidebar(sidebarMenu(
        menuItem("Dashboard", icon = icon("dashboard"), tabName = "dashboard"),
        menuItem("Presidential", icon = icon("calendar"), tabName = "widgets", badgeLabel = "Election Year", badgeColor = "green"),
        # menuItem("years", icon = icon("calendar"),
        #          menuSubItem("sub-item1", tabName = "subitem1")),

        selectInput("select_yr", label = "Select election year", choices = c(unique(elections_historic$year)))
        #tableOutput("yrs")
        ## Themes for graph
       # box(background = "olive", width = 3,
            # radioButtons("theme", "Choose a theme for the graph", choiceNames = c("Dark mode",
            #                                                                       "Gray mode",
            #                                                                       "Classic mode",
            #                                                                       "Light mode",
            #                                                                       "BW mode",
            #                                                                       "Void mode"),
            #              choiceValues = c("theme_set(theme_dark())", "theme_set(theme_gray())", "theme_set(theme_classic())", 
            #                               "theme_set(theme_light())", "theme_set(theme_bw())", "theme_set(theme_void())"
            #              ) 
            # )
        #)
    )
    
    ),
    
    dashboardBody(fluidRow(
        # A static valueBox
        #valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
        
        # Dynamic valueBoxes
        valueBoxOutput("winner"),
        
        valueBoxOutput("party_won"),
        valueBoxOutput("vote_won"),
        
        
    ),
    fluidRow(
        valueBoxOutput("electoral_coll"),
        valueBoxOutput("ecTurnout", width = 4)
    ),
    
    fluidRow(
        # box for sliderInput
        box( width = 5,background = "aqua",
            sliderInput("elect_yr", "Select time period for timeseries analysis of election voter turnout",
                        min = 1824,
                        max = 2016,
                        step = 4,
                        sep = "",
                        value = c(1824, 2016)) 
        ),
        
        # line graph plot of votes for selected time period
        box(title = "Voter turnout timeseries ", solidHeader = TRUE, collapsible = TRUE, background = "green",width = 7,
            plotOutput("timeseries", height = 350)),
    ),
    
    fluidRow(
      
        box( 
            # box for describing winner whether unpopular or not 
            title = "Status of victory", width=5, textOutput("status"), background = "yellow"
            #footer = "Losing the popular votes but winning the electoral colleage makes it unpopular victory",
            #textOutput("unpopolarType")
        ),
        # box for ploting bar graph of frequency of party winning for selected period
        box( solidHeader = TRUE, background = "red",
           # footer = "Based on the year span selected we can calculated the frequency of winning election by various parties",
            title = "Party Profile", 
            plotOutput("partyprof")
        )),
                  
    ######### to keep dashboard alive. ##########
    textOutput("keepAlive")
    )
)

 
