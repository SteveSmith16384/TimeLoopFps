class_name Main
extends Spatial

const player_class = preload("res://Player/KinematicCharacter/PlayerKinematicCharacter.tscn")

var time : float = Globals.PHASE_DURATION
var game_over = false
var players = {}; # id/player.  NOT drones
var drones = [];
var phase_num : int = 1
var rewinding = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var num = 0
	for player_id in Globals.player_nums:
		var render = $Splitscreen.add_player(num)
		
		var player = player_class.instance()
		player.player_id = player_id
		player.set_as_player(player_id)
		player.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
		
		render.viewport.add_child(player)
		
		var hud_class = preload("res://PlayerHUD.tscn")
		player.hud = hud_class.instance()
		
		render.viewport.add_child(player.hud)

		players[player_id] = player
		
		num += 1
		pass
		
	start_recording_and_playback()
	pass
	

func _input(event):
	if rewinding:
		return
		
	if players.has(0):
		players[0]._input(event)
	pass
	
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://IntroScene.tscn")
		return
		
	if game_over:
		return
	
	if rewinding:
		var all_finished = true
		# Check if finished
		for p in players.values():
			if p.has_finished_rewinding() == false:
				all_finished = false
				break
		if all_finished:
			finished_rewinding()

	time -= delta
	if time < 0:
		time = 0
		if rewinding == false:
			end_of_phase()
	pass


func _on_HudTimer_timeout():
	$HUD.update_time_label(time)
	pass


func start_recording_and_playback():
	for p in players.values():
		p.find_node("RecordActions").start(Globals.RecMode.Recording)
		
	for d in drones:
		d.find_node("RecordActions").start(Globals.RecMode.Playing)
		
	$AudioStreamPlayer_Start.play()
	pass
	
	
func end_of_phase():
	phase_num += 1
	if phase_num <= 3:
		start_rewinding()
	else:
		game_over = true
		#$HUD.show_winner()
		for player in players.values():
			if player.side == $Arena/ControlPoint.side:
				player.show_winner()
			else:
				player.show_loser()
		# todo - show winner
	pass


func start_rewinding():
	rewinding = true

	for p in players.values():
		p.find_node("RecordActions").start(Globals.RecMode.Rewinding)
		
	for d in drones:
		d.find_node("RecordActions").start(Globals.RecMode.Rewinding)
		
	$AudioStreamPlayer_Rewind.play()
	pass
	
	
func finished_rewinding():
	if rewinding == false:
		return
	
	rewinding = false
	
	time = Globals.PHASE_DURATION
	
	for d in drones:
		d.health = Player.START_HEALTH
		pass
		
		
	for player_id in Globals.player_nums:
		# Move players to start
		var player = players[player_id]
		player.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
		player.health = Player.START_HEALTH
		
		# Create drones
		var drone = player_class.instance()
		drone.player_id = player_id
		var action_data = player.get_action_data()
		drone.set_as_drone(player_id, action_data)
		drone.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
		self.add_child(drone)
		drones.push_back(drone)
		
	start_recording_and_playback()
	pass
	
