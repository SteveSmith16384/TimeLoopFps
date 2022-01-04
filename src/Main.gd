class_name Main
extends Spatial

const player_class = preload("res://Player/KinematicCharacter/PlayerKinematicCharacter.tscn")

var time : float = Globals.PHASE_DURATION
var game_over = false
var players = {}; # id/player.  NOT drones
var drones = [];
var phase_num : int = 1
var rewinding = false

# Turn-based settings
var player_turn_idx : int = 0
var current_player

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var num = 0
	for player_id in Globals.player_nums:
		var player = player_class.instance()
		player.player_id = player_id
		player.set_as_player(player_id)
		player.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
		player.look_at(Vector3.ZERO, Vector3.UP) # Look to middle

		var hud_class = preload("res://PlayerHUD.tscn")
		player.hud = hud_class.instance()
		
		if Globals.TURN_BASED:
			add_child(player)
		else:
			var render = $Splitscreen.add_player(num)
			render.viewport.add_child(player)
			render.viewport.add_child(player.hud)

		players[player_id] = player
		
		num += 1
		pass
		
	current_player = players.values()[0]
	current_player.find_node("Camera").current = true
	
	start_recording_and_playback()
	pass
	

func _input(event):
	if rewinding:
		return
		
	if players.has(0):
#		if Globals.TURN_BASED and players[0] != current_player:
#			return
		players[0]._input(event)
	pass
	
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://IntroScene.tscn")
		return
		
	if game_over:
		return
	
	if rewinding:
		# Check if finished
		var all_finished = true
		for p in players.values():
			if Globals.TURN_BASED and p != current_player:
				continue
			if p.has_finished_rewinding() == false:
				all_finished = false
				break
		if all_finished:
			finished_rewinding()
			return
			
	time -= delta
	if time < 0:
		time = 0
		if rewinding == false:
			end_of_phase()
	pass


func _on_HudTimer_timeout():
	$HUD.update_time_label(time, phase_num)
	pass


func start_recording_and_playback():
	for p in players.values():
		if Globals.TURN_BASED == false or p == current_player:
			p.find_node("RecordActions").start(Globals.RecMode.Recording)
		
	for d in drones:
		d.find_node("RecordActions").start(Globals.RecMode.Playing)
		
	$AudioStreamPlayer_Start.play()
	pass
	
	
func end_of_phase():
	phase_num += 1
	if phase_num <= Globals.NUM_PHASES:
		start_rewinding()
	else:
		game_over = true
		phase_num = Globals.NUM_PHASES
		if Globals.TURN_BASED:
			if $Arena/ControlPoint.side < 0:
				$HUD.show_text("DRAW!")
			else:
				$HUD.show_text("THE WINNER IS " + Globals.get_colour_from_side($Arena/ControlPoint.side))
				pass
		else:
			for player in players.values():
				if $Arena/ControlPoint.side < 0:
					player.show_draw()
				elif player.side == $Arena/ControlPoint.side:
					player.show_winner()
				else:
					player.show_loser()
	pass


func start_rewinding():
	rewinding = true

	for p in players.values():
		if Globals.TURN_BASED == false or p == current_player:
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

	var prev_player = current_player
	if Globals.TURN_BASED:
		player_turn_idx += 1
		if player_turn_idx >= players.size():
			player_turn_idx = 0
		current_player = players.values()[player_turn_idx]
			
	for d in drones:
		d.health = Player.START_HEALTH
		pass
		
		
	for player_id in players:
		# Move players to start
		var player = players[player_id]
		player.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
		player.look_at(Vector3.ZERO, Vector3.UP) # Look to middle
		player.health = Player.START_HEALTH
		
		# Create drones
		if Globals.TURN_BASED:
			if player != prev_player: # Only create drones of player who's just been
				continue
				
		var drone = player_class.instance()
		drone.player_id = player_id
		var action_data = player.get_action_data()
		drone.set_as_drone(player_id, action_data)
		drone.translation = get_node("StartPositions/StartPosition" + str(player_id)).translation
		#drone.look_at(Vector3.ZERO, Vector3.UP) # Look to middle
		self.add_child(drone)
		drones.push_back(drone)
		
	if Globals.TURN_BASED:
		current_player.find_node("Camera").current = true

	start_recording_and_playback()
	pass
	
