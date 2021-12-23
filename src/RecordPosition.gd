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
		var data = {
			pos = self.owner.translation,
			time = OS.get_ticks_msec() - start_time,
			rot = self.owner.rotation
		}
		positions.push_back(data)
	else:
		var time = OS.get_ticks_msec() - start_time
		var peek = positions.front()
		if peek:
			if peek.time <= time:
				owner.translation = peek.pos
				owner.rotation = peek.rot
				positions.remove(0) # todo - use array pointer
	pass 
