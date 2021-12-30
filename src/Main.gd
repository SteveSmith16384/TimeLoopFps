class_name Main
extends Spatial

const tiny_expl = preload("res://TinyExplosion.tscn")
const small_expl = preload("res://SmallExplosion.tscn")
const big_expl = preload("res://BigExplosion.tscn")
const player_class = preload("res://Player/KinematicCharacter/PlayerKinematicCharacter.tscn")

var time : float
var game_over = false
var players = {};
var phase_num : int = 1


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$HUD.update_time_label(time)

	# Add a player. Possible values 0 - 3. Returns a TextureRect with some extra goodies attached
	var num = 0
	for player_id in Globals.player_nums:
		var render = $Splitscreen.add_player(num)
		
		var player = player_class.instance()
		player.player_id = player_id
		player.set_as_player()
		player.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
		
		# Set player colours
#		if player_id == 1:
#		var human_white_class = preload("res://Player/KinematicCharacter/PlayerKinematicCharacter.tscn")
#		var human_white = human_white_class.instance()
#			human_white.name = "Human"
#		player.add_child(human_white)
#		else:
#			var human_yellow_class = preload("res://Human/human_yellow.tscn")
#			var human_yellow = human_yellow_class.instance()
#			human_yellow.name = "Human"
#			player.add_child(human_yellow)
#			pass
			
		render.viewport.add_child(player)
		
		var hud_class = preload("res://PlayerHUD.tscn")
		player.hud = hud_class.instance()
		
		render.viewport.add_child(player.hud)

		players[player_id] = player
		
		num += 1
		pass
		
	start_recording()
	$Sounds/AudioAmbience.play()
	pass
	

func _input(event):
	if players.has(0):
		players[0]._input(event)
	pass
	
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://IntroScene.tscn")
		return
		
	if game_over:
		return
		
	time += delta
	pass


func collision(mover, hit):
	if hit.has_method("collided"):
		hit.collided(mover)
	pass


func tiny_explosion(spatial):
	var i = tiny_expl.instance()
	add_child(i)
	i.translation = spatial.global_transform.origin
	pass
	
	
func small_explosion(spatial):
	var i = small_expl.instance()
	add_child(i)
	i.translation = spatial.global_transform.origin
	pass
	
	
func big_explosion(spatial):
	var i = big_expl.instance()
	add_child(i)
	i.translation = spatial.global_transform.origin
	pass
	

func _on_HudTimer_timeout():
	$HUD.update_time_label(time)
	pass


func start_recording():
	var recs : Array = Globals.recorders
	for recorder in recs:
		if recorder != null:
			recorder.start_recording()
	pass
	
	
func _on_Timer_Rewind_timeout():
	start_playback()
	pass


func start_playback():
	for player_id in Globals.player_nums:
		var player = players[player_id]
		player.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation

		# Create drones
		var drone = player_class.instance()
		drone.player_id = player_id
		var action_data = player.get_action_data()
		drone.set_as_drone(action_data)
		drone.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
	pass
	
