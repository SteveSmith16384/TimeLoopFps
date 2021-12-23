extends Spatial


func _ready():
	if $AudioStreamPlayer:
		$AudioStreamPlayer.play()
	pass
	
	
func _on_Timer_timeout():
	queue_free()
	pass
