library(shiny)
shinyUI(fluidPage(
  titlePanel("Classic mpg predictor"),
  fluidRow(
    column(3,wellPanel(
      h4('This app predicts the milage per galon of classic cars from 1970 to 1982 by 
        fitting a linear regression model.
         If you own a car from that period and want to know how far you can go,
         introduce the data from your car. If you do not know about some fields, 
         deselect them from the list'),
      h5('Fields to include in the model:'),
      checkboxInput('ch_cylinder','Cylinder',value=T),
      checkboxInput('ch_displacement','Displacement',value=T),
      checkboxInput('ch_horsepower','Horsepower',value=T),
      checkboxInput('ch_weight','Weight',value=T),
      checkboxInput('ch_acceleration','Acceleration',value=T),
      checkboxInput('ch_model_year','Model year',value=T),
      h4('More information at:'),
      a("Auto MPG dataset", href="https://archive.ics.uci.edu/ml/datasets/auto+mpg")
    )),
    
    column(2,wellPanel(
      h4('Introduce the car characteristics and submit'),
      numericInput('cylinders','Cylinders:',min=3,max=8, value=5, step=1),
      textInput('displacement', 'Displacement:',value='150'),
      textInput('horsepower','Horsepower:', value='100'),
      textInput('weight','Weight:', value='2800'),
      textInput('acceleration', 'Acceleration:', value='15'),
      numericInput('model_year', 'Model year:', min=70,max=82, value=75, step=1),
      actionButton('submit','Submit',class = "btn-primary")
    )),
    column(4,wellPanel(
      plotOutput("fit")
    )),
    column(3,wellPanel(
      verbatimTextOutput("fitText")
    ))
  )
))
