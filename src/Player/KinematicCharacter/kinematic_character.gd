extends KinematicBody
class_name KinematicCharacter


class Surface:
	var character:KinematicCharacter
	var collider:Spatial
	var travel:Vector3
	var remainder:Vector3
	var normal:Vector3
	var impact_normal:Vector3
	var impact_point:Vector3
	var impact_point_on_character:Vector3
	var collision_position:Vector3
	var character_shape:CollisionShape
	var collider_shape:CollisionShape
	
	var collider_global_basis_on_impact:Basis
	
	func _init(character:KinematicCharacter, collision:KinematicCollision):
		character = character
		
		collider = collision.collider
		travel = collision.travel
		remainder = collision.remainder
		
		impact_point = collision.position
		impact_point_on_character = character.to_local(collision.position)
		collision_position = collision.position
		character_shape = collision.local_shape
		collider_shape = collision.collider_shape
		normal = collision.normal
		
		var space_state = character.get_world().direct_space_state
		var origin = character.to_global(impact_point_on_character)
		var floor_distance = character._att_floor_normal().normalized()*character._att_floor_max_distance()
		var result = space_state.intersect_ray(origin + floor_distance/2, origin - floor_distance, [self])
		if result:
			impact_normal = result.normal
		else:
			impact_normal = Vector3.ZERO
		
		collider_global_basis_on_impact = collider.global_transform.basis.orthonormalized()
	
	
	func friction() -> float:
		if collider.get("physics_material_override") and collider.physics_material_override is PhysicsMaterial:
			return collider.physics_material_override.friction
		if collider.get("friction") and collider.friction is float:
			return collider.friction
		return 1.0


var _mouse_position = Vector2(0.0, 0.0)
var _yaw = 0.0
var _pitch = 0.0
var _total_yaw = 0.0
var _total_pitch = 0.0

var _base_view_rotation:Basis = Basis()
var _control_view_rotation:Basis = Basis()

var _vertical_direction:Vector3 = Vector3.UP

var _remaining_jump_time:float = 0
var _remaining_air_jumps:int = 0
var _remaining_wall_jumps:int = 0
enum JumpType {NO_JUMP = 0, AIR_JUMP, WALL_JUMP, FLOOR_JUMP}
var _jump_type:int = JumpType.NO_JUMP

var _is_applying_move_input:bool = false
var _control_movement_input:Vector3 = Vector3.ZERO
var _last_valid_control_movement_input:Vector3 = Vector3.ZERO



var movement_input:Vector2 = Vector2.ZERO
var current_floor:Surface setget , get_current_floor
var current_attached_wall:KinematicCollision setget , get_current_attached_wall

var velocity:Vector3 = Vector3.ZERO
var additional_gravitational_impulse:Vector3 = Vector3.ZERO

var last_gravity_impulse:Vector3 = Vector3.ZERO setget, get_last_gravity_impulse



func _ready():
	Input.set_mouse_mode(2)

func _process(delta):
	_update_mouselook()
	_update_base_view_rotation(delta)
	_update_control_view_rotation()

func _physics_process(delta):
	_update_rotation_on_current_floor()
	_update_control_movement_input()
	_update_motion(delta)
	_update_number_of_jumps()

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative

#----------Character Attribute Functions----------

func _att_mouse_smoothness() -> float: return 0.5
func _att_yaw_limit() -> float: return 360.0
func _att_pitch_limit() -> float: return 89.5
func _att_vertical_mouse_sensitivity() -> float: return 0.5
func _att_horizontal_mouse_sensitivity() -> float: return 0.5

func _att_max_speed() -> float: return 3000.0
func _att_max_slides_per_iteration() -> int: return 4

func _att_base_view_up_direction() -> Vector3: return Vector3.UP

func _att_radial_forward_control_movement_input() -> bool: return true
func _att_radial_right_control_movement_input() -> bool: return false
func _att_movement_control_speed() -> float: return 20.0
func _att_movement_control_acceleration() -> float: return 100.0

func _att_falling_speed() -> float: return 20.0
func _att_falling_speed_factor_on_attached_wall() -> float: return 0.1
func _att_stop_on_slope_when_landing() -> bool: return true

func _att_gravity_scale() -> float: return 5.0
func _att_ignore_gravity_if_apply_additional_gravity_impulse() -> bool: return true

func _att_floor_normal() -> Vector3: return Vector3.UP
func _att_floor_max_angle() -> float: return 0.785398
func _att_floor_min_distance() -> float: return 0.05
func _att_floor_max_distance() -> float: return 0.1
func _att_apply_gravity_impulse_on_walking() -> bool: return false
func _att_maintain_horizontal_velocity_walking() -> bool: return true
func _att_floor_friction() -> float: return 1.0


func _att_jump_direction() -> Vector3: return Vector3.UP
func _att_jump_impulse() -> float: return 20.0
func _att_jump_speed() -> float: return 15.0
func _att_jump_time() -> float: return 0.5
func _att_attach_to_wall() -> bool: return true
func _att_attached_wall_jumps() -> int: return -1
func _att_air_jumps() -> int: return 0

func _att_stop_jumping_on_ceiling() -> bool: return false
func _att_apply_gravity_in_jump() -> bool: return false


func _att_physics_rotation_up_direction() -> Vector3: return Vector3.UP
func _att_vertical_physics_rotation_update_velocity() -> float: return 15.0

enum HorizontalPhysicsRotationUpdateType {NO_UPDATE = 0, CONTROL_INPUT, LAST_VALID_CONTROL_INPUT, VELOCITY_DIRECTION, CAMERA_ORIENTATION}
func _att_horizontal_physics_rotation_update_type() -> int: return HorizontalPhysicsRotationUpdateType.CONTROL_INPUT
func _att_horizontal_physics_rotation_update_velocity() -> float: return 10.0
func _att_rotate_to_attached_wall() -> bool: return true

#----------End of Character Attribute Functions----------

func _update_mouselook():
	var mouse_smoothness: = _att_mouse_smoothness()
	var vertical_mouse_sensitivity = _att_vertical_mouse_sensitivity()
	var horizontal_mouse_sensitivity = _att_horizontal_mouse_sensitivity()
	var yaw_limit: = _att_yaw_limit()
	var pitch_limit = _att_pitch_limit()
	
	_mouse_position *= Vector2(vertical_mouse_sensitivity, horizontal_mouse_sensitivity)
	_yaw = _yaw * mouse_smoothness + _mouse_position.x * (1.0 - mouse_smoothness)
	_pitch = _pitch * mouse_smoothness + _mouse_position.y * (1.0 - mouse_smoothness)
	_mouse_position = Vector2(0, 0)

	if yaw_limit < 360:
		_yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
	if pitch_limit < 360:
		_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)

	_total_yaw += _yaw
	_total_pitch += _pitch

func _update_base_view_rotation(delta):
	var up:Vector3 = _att_base_view_up_direction().normalized()
	if !up.is_normalized():
		return
	
	var left = _base_view_rotation.xform(Vector3.LEFT)
	
	var forward
	up = up.normalized()
	forward = up.cross(left).normalized()
	left = forward.cross(up)
	
	_base_view_rotation = _base_view_rotation.slerp(Basis(-left, up, forward).orthonormalized(), 10*delta).orthonormalized()

func _update_control_view_rotation():
	var quat = Quat.IDENTITY
	quat.set_euler(_control_view_rotation.get_euler() + Vector3(deg2rad(-_pitch), deg2rad(-_yaw), 0))
	_control_view_rotation = Basis(quat).orthonormalized()

func _update_current_floor(floor_normal:Vector3) -> void:
	if (.is_on_floor() or current_floor != null) and is_not_jumping() and floor_normal:
		var rel_vec = -floor_normal*_att_floor_max_distance()
		var collision = move_and_collide(rel_vec, false, true, true)
		if collision != null and (.is_on_floor() or collision.normal.angle_to(floor_normal) <= _att_floor_max_angle()):
			current_floor = Surface.new(self, collision)
			var travel_length = current_floor.travel.length()
			move_and_collide(-floor_normal*(travel_length - _att_floor_min_distance()))
		else:
			current_floor = null
	else:
		current_floor = null

func _update_attached_wall() -> void:
	if _att_attach_to_wall() and is_on_wall() and _control_movement_input != Vector3.ZERO:
		var normal = _control_movement_input.normalized()
		if !normal.is_normalized():
			normal = global_transform.basis.xform(Vector3.FORWARD)
		current_attached_wall = find_collision_with_closest_normal_to(normal)
	else:
		current_attached_wall = null

func _update_control_movement_input() -> void:
	if movement_input == Vector2.ZERO:
		_control_movement_input = Vector3.ZERO
		return
	
	
	var rotation = view_rotation()
	
	var up:Vector3 = _vertical_direction
	var right:Vector3 = rotation.xform(Vector3.RIGHT)
	var forward:Vector3 = right.cross(up).normalized()
	right = forward.cross(up).normalized()
	var basis_right: = Basis(right, up, forward)
	
	up = _vertical_direction
	forward = rotation.xform(Vector3.FORWARD)
	right = forward.cross(up).normalized()
	forward = up.cross(right).normalized()
	var basis_forward = Basis(right, up, forward)
	
	
	if _att_radial_forward_control_movement_input():
		_control_movement_input = basis_right.xform(Vector3(0, 0, movement_input.y))
	else:
		_control_movement_input = -basis_forward.xform(Vector3(0, 0, movement_input.y))
	if _att_radial_right_control_movement_input():
		_control_movement_input += basis_forward.xform(Vector3(movement_input.x, 0, 0))
	else:
		_control_movement_input -= basis_right.xform(Vector3(movement_input.x, 0, 0))
	
	_control_movement_input = horizontal_projection(_control_movement_input)
	
	_control_movement_input = _control_movement_input.normalized()*min(movement_input.length(), 1)
	_last_valid_control_movement_input = _control_movement_input

func _update_vertical_direction(var jump_normal:Vector3, floor_normal:Vector3):
	if is_jumping() and jump_normal.is_normalized():
		_vertical_direction = jump_normal
	elif is_on_floor() and floor_normal.normalized():
		if _att_maintain_horizontal_velocity_walking():
			_vertical_direction = current_floor.normal
		else:
			_vertical_direction = floor_normal
	else:
		var accumulated_gravity_normal = last_gravity_impulse.normalized()
		if accumulated_gravity_normal.is_normalized():
			_vertical_direction = -accumulated_gravity_normal
		else:
			var gravity_normal = gravity().normalized()
			if gravity_normal.is_normalized():
				_vertical_direction = -gravity_normal
			else:
				var gravitational_impulse_normal = additional_gravitational_impulse.normalized()
				if gravitational_impulse_normal.is_normalized():
					_vertical_direction = -gravitational_impulse_normal

func _update_rotation_on_current_floor() -> void:
	if current_floor:
		var global_transform_basis = global_transform.basis.orthonormalized()
		var up = global_transform_basis.xform(Vector3.UP).normalized()
		var forward = global_transform_basis.xform(Vector3.FORWARD).normalized()
		forward = current_floor.collider.global_transform.basis.orthonormalized().xform(current_floor.collider_global_basis_on_impact.xform_inv(forward))
		var right = forward.cross(up).normalized()
		forward = up.cross(right)
		var basis = Basis(right, up, -forward)
		
		global_transform = Transform(basis.orthonormalized(), global_transform.origin)

func _update_movement_walking(delta, floor_normal:Vector3):
	var new_velocity = velocity
	var friction:float = _att_floor_friction()
	if _att_apply_gravity_impulse_on_walking():
		new_velocity += _gravity_impulse()*(1 - friction)*delta
	
	var snap:Vector3 = -current_floor.normal*_att_floor_max_distance()
	var vertical_velocity:Vector3
	vertical_velocity = vertical_projection(new_velocity)
	var horizontal_velocity:Vector3 = new_velocity - vertical_velocity
	horizontal_velocity = _calculate_control_horizontal_velocity(delta, horizontal_velocity, _att_movement_control_speed(), _att_movement_control_acceleration(), friction)
	
	
	new_velocity = horizontal_velocity
	
	var max_speed: = _att_max_speed()
	if new_velocity.length_squared() > pow(max_speed, 2): 
		new_velocity = new_velocity.normalized()*max_speed
	
	velocity = move_and_slide_with_snap(new_velocity, snap, floor_normal, true, _att_max_slides_per_iteration(), clamp(_att_floor_max_angle(), 0, 3.141593), false)

func _update_movement_falling(delta, floor_normal):
	var new_velocity = velocity + _gravity_impulse()*delta
	var vertical_velocity = vertical_projection(new_velocity)
	
	var jump_speed = _att_jump_speed()
	var should_apply_jump_speed:bool = is_jumping() and vertical_velocity.length() < jump_speed
	if (should_apply_jump_speed and !_att_apply_gravity_in_jump()):
		new_velocity = velocity
		vertical_velocity = vertical_projection(new_velocity)
	
	var horizontal_velocity = new_velocity - vertical_velocity
	var movement_control_speed = _att_movement_control_speed()
	var falling_speed:float = _att_falling_speed()
	if is_attached_to_a_wall():
		var factor = clamp(_att_falling_speed_factor_on_attached_wall(), 0, 1)
		falling_speed *= factor
		movement_control_speed *= factor
	horizontal_velocity = _calculate_control_horizontal_velocity(delta, horizontal_velocity, movement_control_speed, _att_movement_control_acceleration())
	
	if is_jumping():
		_remaining_jump_time -= delta
		if _remaining_jump_time > delta:
			if should_apply_jump_speed: vertical_velocity = jump_speed * _vertical_direction
		else:
			_remaining_jump_time = 0
			if should_apply_jump_speed and _remaining_jump_time > 0: vertical_velocity = jump_speed * _vertical_direction * (1 - _remaining_jump_time/delta)
			end_jumping()
	else:
		if vertical_velocity.length_squared() > pow(falling_speed, 2) and vertical_velocity.dot(_vertical_direction) < 0:
			vertical_velocity = vertical_velocity.normalized()*falling_speed
	
	new_velocity = horizontal_velocity + vertical_velocity
	
	if new_velocity.length_squared() > pow(_att_max_speed(), 2): 
		new_velocity = new_velocity.normalized()*_att_max_speed()
	
	velocity = move_and_slide(new_velocity, floor_normal, _att_stop_on_slope_when_landing(), _att_max_slides_per_iteration(), clamp(_att_floor_max_angle(), 0, 3.141593), false)

func _update_movement(delta, floor_normal:Vector3) -> void:
	if is_on_floor():
		_update_movement_walking(delta, floor_normal)
	else:
		_update_movement_falling(delta, floor_normal)
	
	last_gravity_impulse = _gravity_impulse()
	additional_gravitational_impulse = Vector3.ZERO

func _rotate_character_to_up_and_forward(up:Vector3, forward:Vector3, alpha:float = 1):
	if (alpha <= 0) or !(up.is_normalized() and forward.is_normalized()) or (up == forward):
		return
	
	var right:Vector3 = forward.cross(up).normalized()
	forward = right.cross(up)
	
	var basis = Basis(right, up, forward).orthonormalized()
	if alpha >=1:
		transform.basis = basis
	else:
		transform.basis = transform.basis.orthonormalized().slerp(basis, alpha).orthonormalized()

func _update_physics_vertical_rotation(delta) -> void:
	var up:Vector3 = _att_physics_rotation_up_direction().normalized()
	var vertical_physics_rotation_update_velocity = _att_vertical_physics_rotation_update_velocity()
	if vertical_physics_rotation_update_velocity <= 0 or !up.is_normalized():
		return
	
	var forward:Vector3 = global_transform.basis.xform(Vector3.FORWARD).normalized()
	var alpha = vertical_physics_rotation_update_velocity*delta
	_rotate_character_to_up_and_forward(up, forward, alpha)

func _update_physics_horizontal_rotation(delta) -> void:
	var horizontal_physics_rotation_update_velocity: = _att_horizontal_physics_rotation_update_velocity()
	if horizontal_physics_rotation_update_velocity <= 0:
		return
	
	var forward
	
	if _att_rotate_to_attached_wall() and is_attached_to_a_wall() and is_falling():
		forward = -current_attached_wall.normal
	else:
		match _att_horizontal_physics_rotation_update_type():
			HorizontalPhysicsRotationUpdateType.CONTROL_INPUT:
				forward = _control_movement_input
				if forward == Vector3.ZERO:
					return
			HorizontalPhysicsRotationUpdateType.LAST_VALID_CONTROL_INPUT:
				forward = _last_valid_control_movement_input
				if forward == Vector3.ZERO:
					return
			HorizontalPhysicsRotationUpdateType.VELOCITY_DIRECTION:
				var horizontal_velocity = horizontal_projection(velocity)
				if horizontal_velocity.length_squared() < 0.0000001:
					return
				forward = horizontal_velocity.normalized()
			HorizontalPhysicsRotationUpdateType.CAMERA_ORIENTATION:
				forward = view_rotation().xform(Vector3.FORWARD)
			_:
				return
	
	var alpha:float = horizontal_physics_rotation_update_velocity*delta
	face_character_to_direction(forward, alpha)

func _update_rotation(delta) -> void:
	_update_physics_vertical_rotation(delta)
	_update_physics_horizontal_rotation(delta)

func _update_motion(delta) -> void:
	var floor_normal = _att_floor_normal().normalized()
	var jump_normal = jump_normal()
	
	_update_movement(delta, floor_normal)
	_update_current_floor(floor_normal)
	_update_attached_wall()
	_update_vertical_direction(jump_normal, floor_normal)
	
	_update_rotation(delta)

func _update_number_of_jumps():
	if is_on_floor():
			_remaining_air_jumps = _att_air_jumps()
			_remaining_wall_jumps = _att_attached_wall_jumps()

func _calculate_control_horizontal_velocity(var delta:float, var current_horizontal_velocity:Vector3, var speed:float, var acceleration:float, friction:float = 1.0) -> Vector3:
	var desirable_velocity = _control_movement_input * speed
	if is_inf(acceleration):
		return desirable_velocity
	
	var max_delta_speed = acceleration*friction*delta
	var delta_speed = (current_horizontal_velocity - desirable_velocity).length();
	if delta_speed < max_delta_speed:
		return desirable_velocity
	
	return current_horizontal_velocity - (current_horizontal_velocity - desirable_velocity).normalized()*max_delta_speed

func _select_acceleration_or_brake(acceleration:float, brake:float):
	if is_braking():
		if _is_applying_move_input:
			return max(acceleration, brake)
		else:
			return brake
	else:
		return acceleration

func is_on_floor() -> bool:
	return current_floor != null

func get_control_movement_input():
	return _control_movement_input

func get_vertical_direction() -> Vector3:
	return _vertical_direction

func get_last_gravity_impulse() ->Vector3:
	return last_gravity_impulse

func get_current_floor() -> Surface:
	return current_floor

func get_current_attached_wall() -> KinematicCollision:
	return current_attached_wall

func is_jumping() -> bool:
	return _jump_type > 0

func is_not_jumping() -> bool:
	return _jump_type <= 0

func is_attached_to_a_wall() -> bool:
	return current_attached_wall != null

func is_falling() -> bool:
	return current_floor == null or is_jumping()

func is_braking() -> bool:
	return velocity != Vector3.ZERO and velocity.dot(_control_movement_input) <= 0

func find_collision_with_closest_normal_to(normal:Vector3) -> KinematicCollision:
	if normal.is_normalized() and get_slide_count() > 0:
		var collision := get_slide_collision(0)
		if get_slide_count() > 1:
			var dot := collision.normal.dot(normal)
			var current_collision := get_slide_collision(1)
			var index := 1
			while current_collision != null:
				var current_dot := current_collision.normal.dot(normal)
				if current_dot > dot:
					dot  = current_dot
					collision = current_collision
				index += 1
				current_collision = get_slide_collision(index)
			
		return collision
	
	return null

func get_friction_of_collision(var collision:KinematicCollision):
	if collision != null:
		var collider: = collision.collider
		if collider.get("physics_material_override") and collider.physics_material_override is PhysicsMaterial:
			return collider.physics_material_override.friction
		if collider.get("friction") and collider.friction is float:
			return collider.friction
	return 1.0

func view_rotation() -> Basis: return (_base_view_rotation*_control_view_rotation).orthonormalized()
func view_direction() -> Vector3: return view_rotation().xform(Vector3.FORWARD)

func gravity() -> Vector3:
	return _att_gravity_scale() * PhysicsServer.area_get_param(get_world().space, PhysicsServer.AREA_PARAM_GRAVITY) * PhysicsServer.area_get_param(get_world().space, PhysicsServer.AREA_PARAM_GRAVITY_VECTOR)

func _gravity_impulse() -> Vector3:
	if _att_ignore_gravity_if_apply_additional_gravity_impulse() and additional_gravitational_impulse != Vector3.ZERO:
		return additional_gravitational_impulse
	return gravity() + additional_gravitational_impulse

func jump_normal():
	return _att_jump_direction().normalized()

func start_falling() -> void:
	current_floor = null

func start_jumping():
	var jump_normal:Vector3 = jump_normal()
	if jump_normal.is_normalized() and is_not_jumping() and !(_att_stop_jumping_on_ceiling() and is_on_ceiling()):
		if is_on_floor():
			_jump_type = JumpType.FLOOR_JUMP
			start_falling()
			_update_vertical_direction(jump_normal, _att_floor_normal().normalized())
		elif is_attached_to_a_wall() and _remaining_wall_jumps != 0:
			_jump_type = JumpType.WALL_JUMP
			if _remaining_wall_jumps > 0:
				_remaining_wall_jumps -= 1
		elif _remaining_air_jumps != 0:
			_jump_type = JumpType.AIR_JUMP
			if _remaining_air_jumps > 0:
				_remaining_air_jumps -= 1
		
		if is_jumping():
			_remaining_jump_time = _att_jump_time()
			
			var jump_impulse: = _att_jump_impulse()
			if velocity.dot(jump_normal) < jump_impulse:
				velocity = velocity - velocity.project(jump_normal) + jump_impulse*jump_normal

func end_jumping() -> void:
	_jump_type = JumpType.NO_JUMP

func vertical_projection(vector:Vector3) -> Vector3:
	return vector.project(_vertical_direction)

func horizontal_projection(vector:Vector3) -> Vector3:
	return vector - vertical_projection(vector)

func vertical_and_horizontal_projections(vector:Vector3) -> Dictionary:
	var vertical_projection = vector.project(_vertical_direction)
	var horizontal_projection = vector - vertical_projection
	return {"vertical" : vertical_projection, "horizontal" : horizontal_projection}

func face_character_to_direction(direction:Vector3, alpha:float = 1):
	_rotate_character_to_up_and_forward(global_transform.basis.xform(Vector3.UP), direction, alpha)

