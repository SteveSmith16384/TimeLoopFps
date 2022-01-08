extends Node2D


func _ready():
	$DebugMode.visible = !Globals.RELEASE_MODE
	$InGame/CenterContainer2/Targetter.visible = Globals.TURN_BASED
	
	if Globals.SHOW_FPS:
		$FPS_Timer.start()
	pass


func update_time_label(time : int, phase_num : int):
	$InGame/CenterContainer/TimeLabel.set_text("TIME: " + str(time) + " PHASE: " + str(phase_num))
	pass
	
	
func _on_Timer_timeout():
	$FPSLabel.set_text("FPS: " + str(Engine.get_frames_per_second()))
	pass


func show_text(text):
	$InGame/Label_Main.visible = true
	$InGame/Label_Main.text = text
	pass
	
