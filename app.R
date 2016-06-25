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

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
   
   # Application title
   titlePanel("Schelling Segregation Simulation"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         numericInput("n", "Number of points",
         						 1000, min = 2, 10000, step=100),
         numericInput("k", "Num. of nearest neighbors",
         						 10, min = 1, max = 100),
         numericInput("min_k", "Minimum num. of similar neighbors for happiness",
         						 5, min = 1, max = 100),
         numericInput("num_iters", "Number of iterations",
         						 1, min = 1, max = 20)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
))

count_green <- function(colors) sum(colors == "green")
is_happy <- function(group, x_pos, y_pos, k = 10, threshold = 5) {
	nn_indices <- get.knn(cbind(x_pos, y_pos), k=k)$nn.index
	nn_groups <- matrix(group[nn_indices], ncol = k)
	n_greens <- apply(nn_groups, 1, count_green)
	n_similar <- ifelse(group == "green", n_greens, k - n_greens)
	n_similar >= threshold
}

iteration_step <- function(data, k = 10, threshold = 5) {
	
	data %>%
		mutate(was_happy = is_happy(group, x, y, k = k, threshold = threshold),
					 x_new = runif(nrow(data)) %>% ifelse(was_happy, x, .),
					 y_new = runif(nrow(data)) %>% ifelse(was_happy, y, .),
					 is_happy = is_happy(group, x_new, y_new, k = k, threshold = threshold),
					 x = ifelse(is_happy, x_new, x),
					 y = ifelse(is_happy, y_new, y)) %>%
		select(group, x, y)
}

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {
	orig_data <- reactive({
		data_frame("group" = c(rep("green", input$n/2),
							 						rep("blue", input$n/2)),
							 "x" = runif(input$n, 0, 1),
							 "y" = runif(input$n, 0, 1))
	})
	
   output$distPlot <- renderPlot({
   	schelling <- iteration_step(orig_data(), input$k, input$min_k)

   	replicate(input$num_iters - 1, {   	
   		schelling <- iteration_step(schelling, input$k, input$min_k)
   	})

   	
   	ggplot(schelling, aes(x = x, y = y, color = group)) + 
   		geom_point() + theme_bw()
   })
})

# Run the application 
shinyApp(ui = ui, server = server)

