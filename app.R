#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(FNN)
library(jsonlite)
library(schellingWidgets)
library(shinythemes)

reactiveGraphic <- function (outputId) {
	HTML(paste("<div id=\"", outputId, "\"><svg /></div>", sep=""))
}

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(theme = shinytheme("readable"),
   
   # Application title
   titlePanel("Schelling Segregation Simulation"),
   fluidRow(
   	column(4,
   				 includeMarkdown("intro.md")
   	),
   	column(3,
   				 wellPanel(
   				 	numericInput("n", "Number of points",
   				 							 300, min = 2, 10000, step=100),
   				 	numericInput("k", "Num. of nearest neighbors",
   				 							 10, min = 1, max = 100),
   				 	numericInput("min_k", "Minimum num. of similar neighbors for happiness",
   				 							 5, min = 1, max = 100),
   				 	numericInput("num_iters", "Number of iterations",
   				 							 4, min = 1, max = 20)
   				 )
   	),
   	column(5,
   				 scatterOutput("scatter1")
   	)
   )
   
   # Sidebar with a slider input for number of bins 
   
))

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
	# Create starting parameters
	message = reactive({
		list(n = input$n,
				 k = input$k,
				 min_k = input$min_k,
				 num_iters = input$num_iters)
		
	})
	
	# Send data as JSON
	output$scatter1 <- renderScatter({
		scatter(message())
	})
	
})

# Run the application 
shinyApp(ui = ui, server = server)

