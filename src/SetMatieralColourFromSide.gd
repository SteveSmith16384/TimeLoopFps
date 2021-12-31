extends Node


var colors = [Color(1.0, 0.0, 0.0, 1.0),
		  Color(0.0, 1.0, 0.0, 1.0),
		  Color(1.0, 1.0, 0.0, 1.0),
		  Color(0.0, 1.0, 1.0, 1.0),
		  Color(1.0, 0.0, 1.0, 1.0),
		  Color(0.0, 0.0, 1.0, 1.0)]


func update():
	var parent = self.get_parent()
	if parent != null:
		var mat = parent.material
		mat.albedo_color = colors[parent.side];
	pass
	
