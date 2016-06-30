(function() {
	
	var binding = new Shiny.OutputBinding();
	
	binding.find = function(scope) {
		return $(scope).find("#plot");
	};
	
	binding.renderValue = function(el, data) {
		console.log(data);
	};
	
	Shiny.outputBindings.register(binding, "schelling_plot");
	
})();

var schelling_plot = (function() {
	
	function init() {
		
	}
	
	function update() {
		
	}
	
	return { init: init, update: update };
})();