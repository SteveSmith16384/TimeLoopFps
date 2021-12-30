extends Node

var actions = []
var start_time : int
var pointer : int  = 0

func _ready():
	Globals.recorders.push_back(self)
	pass
	
	
func start():
	start_time = OS.get_ticks_msec()
	pass
	
	
func _on_Timer_Playback_timeout():
	var time = OS.get_ticks_msec() - start_time
	var peek = actions[pointer]
	if peek:
		if peek.time <= time:
			pointer += 1
			owner.translation = peek.pos
			owner.rotation = peek.rot
	pass


#func _on_PlaybackActions_ready():
#	Globals.recorders.push_back(self)
#	pass # Replace with function body.


#func _on_PlaybackActions_tree_entered():
#	Globals.recorders.push_back(self)
#	pass # Replace with function body.
