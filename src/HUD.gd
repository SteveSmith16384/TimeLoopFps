extends Node2D


func _ready():
	$DebugMode.visible = !Globals.RELEASE_MODE
	
	if Globals.SHOW_FPS:
		$Timer.start()
	pass


func update_time_label(s : int):
	$InGame/CenterContainer/TimeLabel.set_text("TIME: " + str(s))
	pass
	
	
func _on_Timer_timeout():
	$FPSLabel.set_text("FPS: " + str(Engine.get_frames_per_second()))
	pass

