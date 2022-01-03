extends Node

var actions = []
var start_time : int
var pointer : int  = 0
var mode # : Globals.RecMode
var end_time : int

func _ready():
	pass
	
	
func start(_mode):
	mode = _mode
	if mode == Globals.RecMode.Recording:
		actions = []
		$Timer_StorePos.wait_time = 0.05
	elif mode == Globals.RecMode.Playing:
		pointer = 0
		$Timer_StorePos.wait_time = 0.05
	elif mode == Globals.RecMode.Rewinding:
		pointer = actions.size()-1
		end_time = actions[pointer].time
		$Timer_StorePos.wait_time = 0.001
		
	start_time = OS.get_ticks_msec()
	$Timer_StorePos.start() # todo - adjust interval depending on mode
	pass
	
	
func _on_Timer_StorePos_timeout():
	if mode == Globals.RecMode.Recording:
		var data = {
			type = Globals.RecType.Movement,
			pos = self.get_parent().translation,
			time = OS.get_ticks_msec() - start_time,
			rot = self.get_parent().rotation
		}
		actions.push_back(data)
	elif mode == Globals.RecMode.Rewinding:
		if pointer < 0:
			$Timer_StorePos.stop()
			return
			
		var peek = actions[pointer]
		if peek:
			var time = end_time - (OS.get_ticks_msec() - start_time)
			if peek.time >= time/10:
				if peek.type == Globals.RecType.Movement:
					get_parent().translation = peek.pos
					get_parent().rotation = peek.rot
#				elif peek.type == Globals.RecType.Shoot:
#					get_parent().shoot()
				pointer -= 1
	elif mode == Globals.RecMode.Playing:
		if pointer >= actions.size():
			$Timer_StorePos.stop()
			return
			
		var peek = actions[pointer]
		if peek:
			var time = OS.get_ticks_msec() - start_time
			if peek.time <= time:
				if peek.type == Globals.RecType.Movement:
					get_parent().translation = peek.pos
					get_parent().rotation = peek.rot
				elif peek.type == Globals.RecType.Shoot:
					get_parent().shoot()
				pointer += 1
	pass 


func add_shot():
	var data = {
		type = Globals.RecType.Shoot,
		time = OS.get_ticks_msec() - start_time,
	}
	actions.push_back(data)
	pass
	
	
func has_finished_rewinding():
	return pointer <= 0
	pass
	
