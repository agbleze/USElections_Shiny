### global.R

elections_historic <- socviz::elections_historic
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