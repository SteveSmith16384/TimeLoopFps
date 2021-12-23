extends Spatial

var start_label : Label

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Node2D/VersionLabel.set_text("VERSION " + Globals.VERSION);
	
	start_label = find_node("StartLabel")

	pass


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		return

	for i in range(0,4):
		if Input.is_action_just_pressed("primary_fire" + str(i)) or Input.is_action_just_pressed("jump" + str(i)):
			get_tree().change_scene("res://SelectPlayersScene.tscn")
			return

	pass


func _on_Timer_timeout():
	start_label.visible = start_label.visible
	pass
