class_name Player
extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 10#20
const JUMP_SPEED = 14#18
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = .2#0.1

var player_id : int
var drone = false
var hud 

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	pass
	

func set_as_player():
	drone = false
	#$PlaybackActions.queue_free()
	var clazz = preload("res://RecordActions.tscn")
	var i = clazz.instance()
	self.add_child(i)
	i.set_owner(self)
	pass
	
	
func set_as_drone(data):
	drone = true
#	$RecordActions.queue_free()
	var clazz = preload("res://PlaybackActions.tscn")
	var i = clazz.instance()
	self.add_child(i)
	i.set_owner(self)
	i.actions = data
	pass


func _physics_process(delta):
	if drone:
		return
		
	process_input(delta)
	process_movement(delta)
	pass


func process_input(delta):
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("move_forward" + str(player_id)):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backward" + str(player_id)):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left" + str(player_id)):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right" + str(player_id)):
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

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
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
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(-deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	pass


func get_action_data():
	return $RecordActions.actions


