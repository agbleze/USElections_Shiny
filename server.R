# This is the server logic of a Shiny web application. 
#

library(shiny)
library(tidyverse)
library(socviz)

server <- function(input, output, session){
    
    theData <- reactive({
        ## load dataset
        election_dataset <- elections_historic
        #piping the dataset to make it available to other functions without explicitly refering to it
        election_dataset %>%
            select(year, win_party, "President elected" = winner, votes, 
                   "Share_electoral_college_%" = ec_pct,
                   popular_pct, "Popular_vote_margin" = margin, turnout_pct, 
                   "Winner_electoral_college_vote" = ec_votes) %>%
            filter(year >= input$elect_yr[1], year <= input$elect_yr[2])
    })
    
    thePresElectData <- reactive({
        elect_Data <- elections_historic %>%
            select(year, win_party, winner, votes, ec_pct, popular_pct, margin, ec_votes, popular_margin)%>%
            filter(year == input$select_yr)
    })
    
    ##line title
    # series_title <- reactive({
    #     "Voter turnout timeseries "
    # })
    
    # plot timeseries of voter turnout
    output$timeseries <- renderPlot({
        newn <- input$theme
        thePlot <- theData()%>%
            ggplot(mapping = aes(x = year, y = turnout_pct)) + geom_line() + geom_smooth(method = loess) + theme_bw() 
        # if(input$theme){
        #     thePlot = thePlot + input$theme  
        # } 
        old <- input$theme
        
        print(thePlot)
        
        
    }
        
    )
    ### president elected
    output$winner <- renderValueBox({
        election_winner <- thePresElectData()%>%
            select(winner)
            #filter(winner == input$select_yr)
        election_year <- input$select_yr
        
        valueBox(tags$h3(paste0(election_winner), style = "font-size: 210%"), paste0("Winner of ", election_year, " elections"), 
                 icon = icon("user"), color = "maroon")
    })
    
    ### party elected
    output$party_won <- renderValueBox({
        elected_party <- thePresElectData()%>%
            select(win_party)
        elected_party_name = if(elected_party == "Dem."){
            "Democrat"
        } else if(elected_party == "Rep."){
            "Republican"
        } else{
            "Whig"
        }
        
        ## create different icons for different winning parties
        party_icon<- if(elected_party == "Dem."){
            dem = icon("democrat")
        } else if(elected_party == "Rep."){
           rep = icon("republican")
        } else{
           whig = icon("flag-usa")
        }
        
        ## create different colours corresponding to winning parties
        party_color <- if(elected_party == "Dem."){
            "blue"
        } else if(elected_party == "Rep."){
            "red"
        } else{
            "orange"
        }
            
        #    icon("democrat")
        # republican <- icon("flag-usa")
        valueBox(paste0(elected_party_name), paste0("Elected Party"), icon = party_icon, 
                 color = party_color)
    })
    
    ### vote_won valuebox
    output$vote_won <- renderValueBox({
        vote_perc <- thePresElectData()%>%
            select(popular_pct)%>%
            mutate(vote_percentage = popular_pct * 100)%>%
            select(vote_percentage)
        
        valueBox(paste0(vote_perc, "%"), paste0("Popular votes won"), icon = icon("vote-yea"), 
                 color = "teal")
    })
    
    ## electoral colleage
    output$electoral_coll <- renderValueBox({
        electoral_college <- thePresElectData()%>%
            select(ec_votes)
        
        ### render to valuebox
        valueBox(paste0(electoral_college), paste0("Electoral college votes secured"), 
                 icon = icon("landmark"), color = "green")
        
    })
    # plot of unpopular type
    output$status <- renderText({
        
        president_elect <- thePresElectData()%>%
            select(winner)
        
        margin_percent <- thePresElectData()%>%
            select(popular_margin)%>%
            mutate(lead_margin = abs(popular_margin * 100)) %>%
            select(lead_margin)
        
        unpop <- paste0(president_elect, " lost the popular vote by ", margin_percent, " % margin." )
        pop <- paste0(president_elect, " won the popular vote by ", margin_percent, " % margin.")
        
        thep <- thePresElectData() %>%
            select(margin)
            
        ifelse(thep < 0, unpop, pop)
    }
        
    )
    
    # plot for party profile
    output$partyprof <- renderPlot({
        ggplot(data = theData()) + geom_bar(aes(win_party, fill = win_party), stat = "count") + theme_classic()
    })
    
    # plot for turnout
    output$ecTurnout <- renderValueBox({
       yearSel <- input$select_yr
        
        turnout <- select(elections_historic, year, turnout_pct)
        filt <- filter(turnout, year == yearSel)
        turnout_per <- mutate(filt, turnoutPercent = turnout_pct * 100) %>%
            select(turnoutPercent)
        
        valueBox(
            value = paste0(turnout_per, "%"), paste0("Eligible voters casted their ballot in ", yearSel ), icon = icon("person-booth"),color = "olive",
        )
    })
}



