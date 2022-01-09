class_name Bomb
extends RigidBody

var main
var ants = []

func _ready():
	main = get_tree().get_root().get_node("Main")
	pass


func _on_Timer_timeout() -> void:
	main.small_explosion(self)
	for ant in ants:
		if can_see(ant):
			ant.killed()
		
	self.queue_free()
	pass


func can_see(ant : Spatial) -> bool:
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(self.translation, ant.translation)
	if result != null:
		return result["collider"] == ant
	else:
		return false
	pass
	
	
func _on_Area_body_entered(body):
	if body.is_in_group("Ants"):
		ants.push_back(body)
	pass


func _on_Area_body_exited(body):
	if body.is_in_group("Ants"):
		ants.erase(body)
	pass
