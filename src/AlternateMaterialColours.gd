extends Node2D

export var interval: float

var time: float
var active = true

var colors = [Color(1.0, 0.0, 0.0, 1.0),
		  Color(0.0, 1.0, 0.0, 1.0),
		  Color(1.0, 1.0, 0.0, 1.0),
		  Color(0.0, 1.0, 1.0, 1.0),
		  Color(1.0, 0.0, 1.0, 1.0),
		  Color(0.0, 0.0, 1.0, 1.0)]
		
		
func _process(delta):
	if not active:
		return
		
	time += delta
	if time > interval:
		time = 0
		var parent = self.get_parent()
		if parent != null:
			var mat = parent.material
			mat.albedo_color = colors[Globals.rnd.randi_range(0, colors.size()-1)];
	pass
	
