extends StaticBody

var player_count = 0

func _ready():
	$CSGBox.visible = false
	pass # Replace with function body.



func _on_VisibleArea_body_entered(body):
	if body.is_in_group("Player"):
		player_count += 1
		$CSGBox.visible = true
	pass


func _on_VisibleArea_body_exited(body):
	if body.is_in_group("Player"):
		player_count -= 1
		if player_count <= 0:
			$CSGBox.visible = false
	pass
	
