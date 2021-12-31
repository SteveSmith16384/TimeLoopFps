extends Area


func _process(delta):
	$CSGSphere.rotate_y(delta)
	pass


func _on_HealthPickup_body_entered(body):
	if body.is_in_group("players"):
		if body.is_alive():
			body.health = 100
			self.queue_free()
	pass
