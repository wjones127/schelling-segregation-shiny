HTMLWidgets.widget({

    name: 'scatter',

    type: 'output',

    factory: function(el, width, height) {

        var current_plot = undefined;

        return {

            renderValue: function(x) {

                if (current_plot !== undefined) current_plot.remove();

                current_plot = schelling_plot(el, width, height, x);


                var control_bar = d3.select(el)
                        .append("div")
                        .classed("control-bar", true);
                control_bar.append("button")
                    .text("Stop")
                    .classed("btn btn-default", true)
                    .on("click", current_plot.stop);
                control_bar.append("button")
                    .text("Start")
                    .classed("btn btn-default", true)
                    .on("click", current_plot.start);
                control_bar.append("button")
                    .text("Next")
                    .classed("btn btn-default", true)
                    .on("click", current_plot.next);

            },

            resize: function(width, height) {

                // TODO: code to re-render the widget with a new size
                current_plot.resize(width, height);

            }

    };
  }
});

function schelling_plot(el, init_width, init_height, full_data) {

    var margin = 60,
        plot_width = init_width - 2 * margin,
        plot_height = init_height - 2 * margin,
        svg = d3.select(el)
            .append("svg")
            .attr({
                width: init_width,
                height: init_height
            }),
        plot = svg.append("g")
            .classed("plot", true)
            .attr("transform", "translate(20, 20)");

    // Getter functions
    function x_pos(d) { return d.x; }
    function y_pos(d) { return d.y; }
    function group(d) { return d.group; }

    // Scales
    var x_scale = d3.scale.linear()
            .domain([0,1])
            .range([0, plot_width]),
        y_scale = d3.scale.linear()
            .domain([0,1])
            .range([plot_height, 0]),
        group_scale = d3.scale.category10();

    // Axes
    var x_axis = d3.svg.axis()
            .scale(x_scale)
            .orient("bottom"),
        y_axis = d3.svg.axis()
            .scale(y_scale)
            .orient("left");

    plot.append("g")
        .attr("class", "axis xaxis")
        .attr("transform", "translate(0," + plot_height + ")")
        .call(x_axis);
    plot.append("g")
        .attr("class", "axis yaxis")
        .call(y_axis);

    var current_iter = 0;
    var intervalTimer = undefined;

    render(full_data.history[current_iter]);

    start();

    // Renders the plot
    function render(data, transition /* optional */) {
        var binding = plot.selectAll("circle")
                .data(data);

        binding.enter()
            .append("circle")
            .attr({
                r: "3px",
                cx: _.compose(x_scale, x_pos),
                cy: _.compose(y_scale, y_pos),
                fill: _.compose(group_scale, group)
            });

        if (transition === undefined || transition === true) {
            binding
                .transition()
                .attr({
                    cx: _.compose(x_scale, x_pos),
                    cy: _.compose(y_scale, y_pos),
                });
        } else {
            binding
                .attr({
                    cx: _.compose(x_scale, x_pos),
                    cy: _.compose(y_scale, y_pos),
                });
        }
    }

    // Transitions to next state
    function next() {
        current_iter = (current_iter + 1) % full_data.history.length;
        var back_to_start = current_iter === 0;
        render(full_data.history[current_iter], !back_to_start);
    }

    function start() {
        intervalTimer = setInterval(next, 1000);
    }

    function stop() {
        clearInterval(intervalTimer);
    }

    // Resize the plot
    function resize(width, height) {
        console.log(width + ', ' + height);

        // Resize SVG
        plot_width = width - 2 * margin;
        plot_height = height - 2 * margin;
        svg.attr({ width: width, height: height });

        // Reset scales
        x_scale = x_scale.range([0, plot_width]);
        y_scale = y_scale.range([plot_height, 0]);
        plot.select(".xaxis").call(x_axis);
        plot.select(".yaxis").call(y_axis);

        // Transition points
        plot.selectAll("circle")
            .data()
            .transition()
            .attr({
                cx: _.compose(x_scale, x_pos),
                cy: _.compose(y_scale, y_pos)
            });
    }

    // Deletes the plot
    function remove() {
        stop();
        svg.remove();
    }

    return { render: render,
             resize: resize,
             remove: remove,
             stop: stop,
             start: start,
             next: next };
}
