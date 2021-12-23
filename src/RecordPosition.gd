extends Node

var positions = []
var start_time : int
var record = true

func start_recording():
	record = true
	start_time = OS.get_ticks_msec()
	$Timer_StorePos.start()
	pass
	
	
func start_playback():
	record = false
	start_time = OS.get_ticks_msec()
#	$Timer_StorePos.start()
	pass
	
	
func _on_Timer_StorePos_timeout():
	if record:
		var pos = self.owner.translation
		var data = {
			position = pos,
			time = OS.get_ticks_msec() - start_time
		}
		positions.push_back(data)
	else:
		var time = OS.get_ticks_msec() - start_time
		var peek = positions.front()
		if peek:
			if peek.time <= time:
				owner.translation = peek.position
				positions.remove(0) # todo - use array pointer
	pass 
