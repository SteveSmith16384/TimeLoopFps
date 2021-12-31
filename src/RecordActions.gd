extends Node


var actions = []
var start_time : int

func _ready():
	Globals.recorders.push_back(self)
	pass
	
	
func start():
	actions = []
	start_time = OS.get_ticks_msec()
	$Timer_StorePos.start()
	pass
	
	
func _on_Timer_StorePos_timeout():
	var data = {
		type = Globals.RecType.Movement,
		pos = self.get_parent().translation,
		time = OS.get_ticks_msec() - start_time,
		rot = self.get_parent().rotation
	}
	actions.push_back(data)
	pass 


func add_shot():
	var data = {
		type = Globals.RecType.Shoot,
		time = OS.get_ticks_msec() - start_time,
	}
	actions.push_back(data)
	pass
	
	
