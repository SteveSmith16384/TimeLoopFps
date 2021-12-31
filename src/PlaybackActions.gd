extends Node

var actions = []
var start_time : int
var pointer : int  = 0

func _ready():
	Globals.recorders.push_back(self)
	pass
	
	
func start():
	start_time = OS.get_ticks_msec()
	pointer = 0
	$Timer_Playback.start()
	pass
	
	
func _on_Timer_Playback_timeout():
	var time = OS.get_ticks_msec() - start_time
	if pointer >= actions.size():
		$Timer_Playback.stop()
		return
		
	var peek = actions[pointer]
	if peek:
		if peek.time <= time:
			pointer += 1
			if peek.type == Globals.RecType.Movement:
				get_parent().translation = peek.pos
				get_parent().rotation = peek.rot
			elif peek.type == Globals.RecType.Shoot:
				get_parent().shoot()
	pass

