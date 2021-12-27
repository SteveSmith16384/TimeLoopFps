class_name Player
extends KinematicBody

const speed = 3.5
const acceleration = 25
const mouse_sensitivity = 0.3
const gravity = .7#.7
const jump_power = 7#8#9

var bullet_class = preload("res://Bullet.tscn")
var bomb_class = preload("res://Bomb.tscn")

var main# : Main

var player_id
var hud
var head : Spatial
var first_person_camera : Camera
var third_person_camera : Camera

var invincible = false
var velocity = Vector3()
var camera_x_rotation = 0
var start_pos : Vector3
var alive = true
var grav_offset = 0
var damsel

var first_person_mode = true

# Third person cam settings
var mouseSensitivity = 0.1
var yaw_y : float = 0.0
var pitch_x : float = -45.0
var origin : Vector3 = Vector3()
var target_dist : float = 3.0
var actual_dist : float = 0

# Gun settings
const laser_fire_rate = 0.2
const clip_size = 8
const laser_reload_rate = 0.8#1
var current_ammo = 0
var can_laser_fire = true
var laser_reloading = false


func _ready():
	if Globals.USE_BOMBS:
		current_ammo = 20
	else:
		current_ammo = clip_size
		
	main = get_tree().get_root().get_node("Main")

	start_pos = self.translation

	current_ammo = clip_size

	head = $Head
	first_person_camera = $Head/FirstPersonCamera
	third_person_camera = $ThirdPersonCamera

	update_camera()
	pass
	

func _input(event): #  Gets called by main for mouse movement!
	if player_id == 0:
		if event is InputEventMouseMotion:
			head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			
			var x_delta = event.relative.y * mouse_sensitivity
			if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90: 
				first_person_camera.rotate_x(deg2rad(-x_delta))
				camera_x_rotation += x_delta
	#
			# Move 3rd-person cam
			var mouseVec : Vector2 = event.get_relative()
			yaw_y = head.rotation_degrees.y#fmod(yaw_y - mouseVec.x * mouseSensitivity, 360.0)
			pitch_x = max(min(pitch_x - mouseVec.y * mouseSensitivity, 90.0), -90.0)
			update_camera()
	pass


func update_camera():
	third_person_camera.set_rotation(Vector3(deg2rad(pitch_x), deg2rad(yaw_y), 0.0))
	third_person_camera.set_translation(origin - actual_dist * third_person_camera.project_ray_normal(get_viewport().get_visible_rect().size * 0.5))
	
	if alive:
		if first_person_mode:
			var rot = head.rotation_degrees.y
			if $Human:
				$Human.rotation_degrees.y = rot + 180
		else:
			#$MeshSpatial.rotation_degrees.y = third_person_camera.rotation_degrees.y
			if $Human:
				$Human.rotation_degrees.y = third_person_camera.rotation_degrees.y + 180
	pass


func get_eyes_position():
	return head.global_transform.origin
	
	
func _physics_process(delta):
	if actual_dist != target_dist:
		actual_dist += (target_dist-actual_dist) * delta * 3
		self.update_camera()
		set_first_person_mode(actual_dist <= 1)
		
	if alive == false:
#		velocity.x = 0
#		velocity.z = 0
#		move_and_slide(velocity, Vector3.UP)
		return
		
	var play_footstep = false
	var on_floor = false
	
	grav_offset -= gravity
	var vec3 = Vector3.ZERO
	vec3.y = grav_offset
	move_and_slide(vec3, Vector3.UP)
	if get_slide_count() > 0:
		if vec3.y < 0:
			grav_offset = 0
			on_floor = true
			
	if Input.is_action_pressed("jump" + str(player_id)):
		if on_floor: 
			on_floor = false
			#$AudioStreamPlayer_Jump.play()
			grav_offset += jump_power
	
	if player_id > 0:
		if Input.is_action_pressed("turn_left" + str(player_id)):
			head.rotate_y(deg2rad(4))
			yaw_y = rad2deg(head.rotation.y)
		elif Input.is_action_pressed("turn_right" + str(player_id)):
			head.rotate_y(deg2rad(-4))
			yaw_y = rad2deg(head.rotation.y)

		if Input.is_action_pressed("look_up" + str(player_id)):
			pitch_x += delta * 100
			pass
		elif Input.is_action_pressed("look_down" + str(player_id)):
			pitch_x -= delta * 100
			pass
		pass

	if Input.is_action_pressed("zoom_in" + str(player_id)):
		target_dist -= 1
		if target_dist < 0:
			target_dist = 0
	elif Input.is_action_pressed("zoom_out" + str(player_id)):
		target_dist += 1
		
	var head_basis
	if first_person_mode:
		head_basis = head.get_global_transform().basis
	else:
		head_basis = third_person_camera.get_global_transform().basis
		
	var direction = Vector3()
	if Input.is_action_pressed("move_forward" + str(player_id)):
		play_footstep = true
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward" + str(player_id)):
		play_footstep = true
		direction += head_basis.z
	
	if Input.is_action_pressed("move_left" + str(player_id)):
		play_footstep = true
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right" + str(player_id)):
		play_footstep = true
		direction += head_basis.x
	
	direction.y = 0
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	if get_slide_count() > 0:
		var coll = get_slide_collision(0).get_collider()
		main.collision(self, coll)
		pass
	
	if play_footstep:
		$Human.anim("Run")
	else:
		$Human.anim("Idle")
	
	if Input.is_action_pressed("primary_fire" + str(player_id)) and can_laser_fire:
		if Globals.USE_BOMBS:
			throw_bomb(head_basis.z)
		else:
			if current_ammo > 0 and not laser_reloading:
				fire_bullet()
			elif not laser_reloading:
				reload()
	
	pass
	
	
func throw_bomb(dir : Vector3):
	can_laser_fire = false
	var bomb : Bomb = bomb_class.instance()
	main.add_child(bomb)
#	$Audio_Shoot.play()
	
	bomb.transform = head.global_transform
	bomb.translation = head.get_node("Muzzle").global_transform.origin
	#var dir : Vector3 = third_person_camera.get_global_transform().basis.z
	dir.y = 0.1
	dir = dir.normalized()
	#print("Dir: " + str(dir))
#	bomb.add_central_force(dir * 50)
	bomb.apply_central_impulse(dir * -5)
	
	yield(get_tree().create_timer(laser_fire_rate), "timeout")
	
	can_laser_fire = true
	pass
	

func fire_bullet():
#	print("Shooting!")
	
	can_laser_fire = false
	current_ammo -= 1
	
	var bullet : Bullet = bullet_class.instance()
	bullet.shooter = self
	main.add_child(bullet)
	$Audio_Shoot.play()
	
	bullet.transform = head.global_transform
	bullet.translation = head.get_node("Muzzle").global_transform.origin
	
	yield(get_tree().create_timer(laser_fire_rate), "timeout")

	if current_ammo <= 0:
		reload()
		
	can_laser_fire = true
	pass


func reload():
	laser_reloading = true

	yield(get_tree().create_timer(laser_reload_rate), "timeout")

	current_ammo = clip_size
	laser_reloading = false
	pass
	

func set_first_person_mode(b):
	if first_person_mode == b:
		return
		
	first_person_mode = b

	#find_node("MeshSpatial").visible = !first_person_mode
	$Human.visible = !first_person_mode
	#main.set_first_person(first_person_mode)

	self.first_person_camera.current = first_person_mode
	self.third_person_camera.current = !first_person_mode
	
	self.update_camera();
	pass


func hit_by_bullet():
	if alive == false:
		return
	
	if invincible:
		return
		
	$Human.anim("Die") # how this not error?
	alive = false
	$Audio_Hit.play()
	$RestartTimer.start()
	
	# Show third person
	if target_dist <= 1:
		self.target_dist = 2
	pass
	

func killed():
	self.hit_by_bullet()
	pass
	
	
func _on_RestartTimer_timeout():
	self.translation = start_pos
	alive = true
	pass


func start_recording():
	$RecordPosition.start_recording()
	pass


func start_playback():
	$RecordPosition.start_playback()
	pass

