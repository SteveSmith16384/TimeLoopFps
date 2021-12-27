extends KinematicCharacter
class_name KinematicCharacterWithExportedAttributes



export var mouse_smoothness:float = 0.5
export var yaw_limit:float = 360.0
export var pitch_limit:float = 89.5
export var vertical_mouse_sensitivity:float = 0.5
export var horizontal_mouse_sensitivity:float = 0.5

enum BaseViewUpType {CUSTOM = 0, FLOOR_NORMAL, GRAVITY_ACCELERATION, GRAVITY_IMPULSE}
export(BaseViewUpType) var base_view_up_type:int = BaseViewUpType.FLOOR_NORMAL
export var custom_base_view_up_direction:Vector3 = Vector3.UP

export var max_slides_per_iteration:int = 4

export var max_speed:float = 3000

export var minimal_movement_input:float = .1
export var on_floor_control_speed:float = 20
export var on_floor_control_acceleration:float = 100
export var attacking_control_speed:float = 0.5
export var attacking_control_acceleration:float = 50
export var falling_control_speed:float = 20
export var falling_control_acceleration:float = 50

export var falling_speed:float = 30.0
export var falling_speed_factor_on_attached_wall:float = 0.1
export var stop_on_slope_when_landing:bool = true

export var gravity_scale:float = 5.0
export var ignore_gravity_if_apply_additional_gravity_impulse:bool = true

enum FloorNormalType {CUSTOM = 0, CURRENT_FLOOR_NORMAL, CURRENT_FLOOR_IMPACT_NORMAL, GRAVITY_ACCELERATION, GRAVITY_IMPULSE}
export(FloorNormalType) var floor_normal_type:int = FloorNormalType.CURRENT_FLOOR_IMPACT_NORMAL
export var custom_floor_normal:Vector3 = Vector3.UP
export var floor_max_angle:float = 0.785398
export var floor_min_distance:float = 0.05
export var floor_max_distance:float = 0.1
export var apply_gravity_impulse_on_walking:bool = false
export var maintain_horizontal_velocity_walking:bool = true
export var friction:float = 1.0
enum FrictionCalculationMode {AVARAGE, MULTIPLICATION, FRICTION_ONLY, CURRENT_FLOOR_FRICTION_ONLY}
export(FrictionCalculationMode) var floor_friction_calculation_mode:int = FrictionCalculationMode.MULTIPLICATION


export var floor_jump_impulse:float = 20.0
export var floor_jump_speed:float = 15.0
export var floor_jump_time:float = 0.5

export var attach_to_wall:bool = true
export var attached_wall_jump_impulse:float = 20.0
export var attached_wall_jump_speed:float = 15.0
export var attached_wall_jump_time:float = 0.0
export var attached_wall_jumps:int = -1

export var air_jump_impulse:float = 20.0
export var air_jump_speed:float = 0.0
export var air_jump_time:float = 0.0
export var air_jumps:int = 1

export var stop_jumping_on_ceiling:bool = false
export var apply_gravity_in_jump:bool = false


enum PhysicsRotationUpDirectionType {CUSTOM = 0, FLOOR_NORMAL, GRAVITY_ACCELERATION, GRAVITY_IMPULSE}
export(PhysicsRotationUpDirectionType) var physics_rotation_up_direction_type:int = PhysicsRotationUpDirectionType.FLOOR_NORMAL
export var custom_physics_rotation_up_direction:Vector3 = Vector3.UP
export var vertical_physics_rotation_update_velocity:float = 15.0

export(HorizontalPhysicsRotationUpdateType) var horizontal_physics_rotation_update_type:int = HorizontalPhysicsRotationUpdateType.CONTROL_INPUT
export var horizontal_physics_rotation_update_velocity:float = 10.0
export var rotate_to_attached_wall:bool = true



func _att_mouse_smoothness() -> float:
	return mouse_smoothness

func _att_yaw_limit() -> float:
	return yaw_limit

func _att_pitch_limit() -> float:
	return pitch_limit

func _att_vertical_mouse_sensitivity() -> float:
	return vertical_mouse_sensitivity

func _att_horizontal_mouse_sensitivity() -> float:
	return horizontal_mouse_sensitivity



func _att_base_view_up_direction() -> Vector3:
	match base_view_up_type:
		BaseViewUpType.FLOOR_NORMAL:
			return _att_floor_normal()
		BaseViewUpType.GRAVITY_ACCELERATION:
			return -gravity()
		BaseViewUpType.GRAVITY_IMPULSE:
			return -last_gravity_impulse
	return custom_base_view_up_direction

func _att_max_slides_per_iteration() -> int:
	return max_slides_per_iteration

func _att_max_speed() -> float:
	return max_speed

func _att_movement_control_speed() -> float:
	if $AnimationTree.is_attacking():
		return attacking_control_speed
	if is_on_floor():
		return on_floor_control_speed
	else:
		return falling_control_speed

func _att_movement_control_acceleration() -> float:
	if $AnimationTree.is_attacking():
		return attacking_control_acceleration
	if is_on_floor():
		return on_floor_control_acceleration
	else:
		return falling_control_acceleration

func _att_falling_speed() -> float:
	return falling_speed

func _att_falling_speed_factor_on_attached_wall() -> float:
	return falling_speed_factor_on_attached_wall

func _att_stop_on_slope_when_landing() -> bool:
	return stop_on_slope_when_landing

func _att_gravity_scale() -> float:
	return gravity_scale

func _att_ignore_gravity_if_apply_additional_gravity_impulse() -> bool: return ignore_gravity_if_apply_additional_gravity_impulse

func _att_floor_normal() -> Vector3:
	match floor_normal_type:
		FloorNormalType.GRAVITY_ACCELERATION:
			return -gravity().normalized()
		FloorNormalType.GRAVITY_IMPULSE:
			return -last_gravity_impulse.normalized()
		FloorNormalType.CURRENT_FLOOR_NORMAL:
			if is_on_floor():
				return current_floor.normal
			else:
				return _vertical_direction
		FloorNormalType.CURRENT_FLOOR_IMPACT_NORMAL:
			if is_on_floor() and current_floor.impact_normal != Vector3.ZERO:
				return current_floor.impact_normal
			else:
				return _vertical_direction
	return custom_floor_normal

func _att_floor_max_angle() -> float:
	return floor_max_angle

func _att_floor_min_distance() -> float:
	return floor_min_distance

func _att_floor_max_distance() -> float:
	return floor_max_distance

func _att_apply_gravity_impulse_on_walking() -> bool:
	return apply_gravity_impulse_on_walking

func _att_maintain_horizontal_velocity_walking() -> bool:
	return maintain_horizontal_velocity_walking

func _att_floor_friction() -> float:
	if !is_on_floor():
		return 0.0
	
	var current_floor_friction = current_floor.friction()
	
	if floor_friction_calculation_mode == FrictionCalculationMode.FRICTION_ONLY:
		return clamp(friction, 0, 1)
	
	match floor_friction_calculation_mode:
		FrictionCalculationMode.AVARAGE:
			current_floor_friction = (friction + current_floor_friction)/2
		FrictionCalculationMode.MULTIPLICATION:
			current_floor_friction = friction*current_floor_friction
	
	return clamp(current_floor_friction, 0, 1)


func _att_jump_direction() -> Vector3:
	if is_on_floor():
		return _att_floor_normal()
	else:
		if is_attached_to_a_wall():
			return (_vertical_direction + current_attached_wall.normal/2)
		else:
			return -last_gravity_impulse

func _att_jump_impulse() -> float:
	return floor_jump_impulse

func _att_jump_speed() -> float:
	match _jump_type:
		JumpType.FLOOR_JUMP:
			return floor_jump_speed
		JumpType.WALL_JUMP:
			return attached_wall_jump_speed
		JumpType.AIR_JUMP:
			return air_jump_speed
		_:
			return 0.0

func _att_jump_time() -> float:
	match _jump_type:
		JumpType.FLOOR_JUMP:
			return floor_jump_time
		JumpType.WALL_JUMP:
			return attached_wall_jump_time
		JumpType.AIR_JUMP:
			return air_jump_time
		_:
			return 0.0

func _att_attach_to_wall() -> bool:
	return attach_to_wall

func _att_attached_wall_jumps() -> int:
	return attached_wall_jumps

func _att_air_jumps() -> int:
	return air_jumps


func _att_stop_jumping_on_ceiling() -> bool:
	return stop_jumping_on_ceiling

func _att_apply_gravity_in_jump() -> bool:
	return apply_gravity_in_jump



func _att_physics_rotation_up_direction() -> Vector3:
	match physics_rotation_up_direction_type:
		PhysicsRotationUpDirectionType.FLOOR_NORMAL:
			return _att_floor_normal()
		PhysicsRotationUpDirectionType.GRAVITY_ACCELERATION:
			return -gravity().normalized()
		PhysicsRotationUpDirectionType.GRAVITY_IMPULSE:
			return -last_gravity_impulse.normalized()
	return custom_physics_rotation_up_direction

func _att_vertical_physics_rotation_update_velocity() -> float:
	return vertical_physics_rotation_update_velocity


func _att_horizontal_physics_rotation_update_type() -> int:
	return horizontal_physics_rotation_update_type

func _att_horizontal_physics_rotation_update_velocity() -> float:
	return horizontal_physics_rotation_update_velocity

func _att_rotate_to_attached_wall() -> bool:
	return rotate_to_attached_wall
