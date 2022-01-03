class_name Player
extends KinematicBody

const START_HEALTH = 10
const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 10
const JUMP_SPEED = 11
const ACCEL = 4.5
const DEACCEL= 16

var dir = Vector3()

const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = .2#0.1

const bullet_clazz = preload("res://Bullet.tscn")

var player_id : int
var drone = false
var hud
var side : int
var health = START_HEALTH
var shot_int : float
var main

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	main = get_tree().get_root().get_node("Main")
	
	self.look_at(Vector3.ZERO, Vector3.UP) # Look to middle	
	pass
	

func set_as_player(_side):
	drone = false
	self.side = _side
	set_colour()
	pass
	
	
func set_as_drone(_side, data):
	drone = true
	side = _side
	set_colour()
	$Rotation_Helper/Camera/PlayerBulb.queue_free()
	$RecordActions.actions = data
	pass


func set_colour():
	$Mesh/Body.mesh.surface_get_material(0).albedo_color = Globals.colors[side]
	pass
	
	
func _physics_process(delta):
	if main == null:
		return # Game not started yet
		
	if drone:
		return
	
	if main.rewinding:
		return
	
	if Globals.TURN_BASED:
		if main.current_player != self:
			return
		
	process_input(delta)
	process_movement(delta)
	check_shooting(delta)
	pass


func process_input(delta):
	dir = Vector3()

	var joypad_vec = Vector2()
	if player_id > 0:
#		if Input.is_action_pressed("turn_left" + str(player_id)):
#			rotate_y(deg2rad(4))
#			pass
#		elif Input.is_action_pressed("turn_right" + str(player_id)):
#			rotate_y(deg2rad(-4))
#			pass
		var x_input = Input.get_action_strength("turn_left" + str(player_id)) - Input.get_action_strength("turn_right" + str(player_id))
		rotate_y(deg2rad(x_input*2))
		
		if Input.is_action_pressed("look_up" + str(player_id)):
			rotation_helper.rotate_x(deg2rad(1))
			pass
		elif Input.is_action_pressed("look_down" + str(player_id)):
			rotation_helper.rotate_x(deg2rad(-1))
			pass
		pass

	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()

	if Input.is_action_pressed("move_forward" + str(player_id)):
		input_movement_vector.y += 1
	elif Input.is_action_pressed("move_backward" + str(player_id)):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left" + str(player_id)):
		input_movement_vector.x -= 1
	elif Input.is_action_pressed("move_right" + str(player_id)):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("jump" + str(player_id)):
			vel.y = JUMP_SPEED
	# ----------------------------------
	pass


func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
	if vel.length() > 0:
		$AnimationPlayer.play("Walking")
	else:
		$AnimationPlayer.play("Idle")
	pass


func _input(event):
	if drone:
		return
	if rotation_helper == null:
		return # Not ready yet
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(-deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	pass


func check_shooting(delta : float):
	shot_int -= delta
	if shot_int > 0:
		return
		
	if Input.is_action_pressed("primary_fire" + str(player_id)):
		shot_int = Globals.SHOT_INTERVAL
		var node = find_node("RecordActions")
		if node != null:
			node.add_shot()
		shoot()
	pass
	

func shoot():
	var bullet = bullet_clazz.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(bullet)
	bullet.shooter = self
	bullet.global_transform = $Rotation_Helper/Camera/Muzzle.global_transform
	
	find_node("AudioStreamPlayer_Shoot" + str(side)).play()
	pass
	

func bullet_hit(dam):
	if health <= 0:
		return

	health -= dam
	if health <= 0:
		health = 0
		$Mesh/Body.mesh.surface_get_material(0).albedo_color = Globals.colors[side].darkened(0.7)
		$AudioStreamPlayer_Ghosted.play()
	pass
	

func is_alive():
	return health > 0
	
	
func get_action_data():
	return $RecordActions.actions


func has_finished_rewinding():
	return $RecordActions.has_finished_rewinding()
	
	
func collected_health():
	health = START_HEALTH


func show_winner():
	hud.show_winner()
	
	
func show_loser():
	hud.show_loser()
	
	
