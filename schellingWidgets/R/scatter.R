#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
scatter <- function(message, width = NULL, height = NULL) {

	print(message)
	
	data <- data_frame("group" = c(rep("green", message$n/2),
												 rep("blue", message$n/2)),
						 "x" = runif(message$n, 0, 1),
						 "y" = runif(message$n, 0, 1)) %>%
		generate_sequence(message$num_iters, message$k, message$min_k)
	
	data$history <- lapply(data$history, toJSON)
	
  # create widget
  htmlwidgets::createWidget(
    name = 'scatter',
    data,
    width = width,
    height = height,
    package = 'schellingWidgets'
  )
}

generate_sequence <- function(orig_data, iters, k, min_k) {
	data <- list(iters = iters,
							 history = list())
	
	data$history[[1]] <- orig_data
	
	for (i in seq(1, iters)) {
		data$history[[i+1]] <- iteration_step(data$history[[i]],
																					k = k, threshold = min_k)
	}
	
	data
}

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


#' Shiny bindings for scatter
#'
#' Output and render functions for using scatter within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a scatter
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name scatter-shiny
#'
#' @export
scatterOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'scatter', width, height, package = 'schellingWidgets')
}

#' @rdname scatter-shiny
#' @export
renderScatter <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, scatterOutput, env, quoted = TRUE)
}
