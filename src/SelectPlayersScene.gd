extends Spatial

func _ready():
	Globals.player_nums.clear()
	
	$Camera.current = true
	
	for side in range(0,4):
		update_player(side)
	pass
	

func update_player(side):
	var node = find_node("Player_" + str(side))
	node.visible = false
	node.side = side
	node.set_colour()
	pass
	
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://IntroScene.tscn")
		
	for i in range(0,4):
		if (Globals.FORCE_MAX_PLAYERS and i <= 1) or Input.is_action_just_pressed("primary_fire" + str(i)) or Input.is_action_just_pressed("jump" + str(i)):
			if Globals.player_nums.has(i) == false:
				Globals.player_nums.push_back(i)
				var human = get_node("Player_" + str(i))
				human.visible = true
				$AudioStreamPlayer_PlayerJoined.play()
				pass
			pass
		pass
		
	if Input.is_action_just_pressed("start_game") or Globals.FORCE_MAX_PLAYERS:
		if Globals.player_nums.size() > 0:
			get_tree().change_scene("res://Main.tscn")
	pass
	

