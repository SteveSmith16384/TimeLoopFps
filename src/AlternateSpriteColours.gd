extends Node2D

export var interval: float

var time: float

var colors = [Color(1.0, 0.0, 0.0, 1.0),
		  Color(0.0, 1.0, 0.0, 1.0),
		  Color(1.0, 1.0, 0.0, 1.0),
		  Color(0.0, 1.0, 1.0, 1.0),
		  Color(1.0, 0.0, 1.0, 1.0),
		  Color(0.0, 0.0, 1.0, 1.0)]
		
		
func _process(delta):
	time += delta
	if time > interval:
		time = 0
		self.get_parent().modulate = colors[Globals.rnd.randi_range(0, colors.size()-1)];
	pass
	
