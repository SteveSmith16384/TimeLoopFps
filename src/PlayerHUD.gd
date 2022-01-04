extends CanvasLayer

func _on_RemoveTextTimer_timeout() -> void:
	$CenterContainer/Label.visible = false
	pass


func show_winner() -> void:
	$CenterContainer/Label.text = "WINNER!"
	$CenterContainer/Label.visible = true
	pass
	

func show_loser():
	$CenterContainer/Label.text = "Loser!"
	$CenterContainer/Label.visible = true
	pass


func show_draw():
	$CenterContainer/Label.text = "Loser!"
	$CenterContainer/Label.visible = true
	pass

