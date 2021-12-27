extends AnimationTree

var is_on_floor: = true
var is_attached_to_a_wall: = false
var velocity: = Vector3.ZERO
var vertical_direction: = Vector3.UP
var is_braking: = false
var _request_attack:int = 0

var current_attack: = 0 setget , get_current_attack

func get_current_attack() -> int:
	if is_attacking():
		return current_attack
	else:
		return 0

func request_attack():
	_request_attack += 1

func is_attacking() -> bool:
	return get("parameters/transition/current") == 3

func _ready():
	active = true

func _process(delta):
	if is_on_floor:
		if _request_attack and get("parameters/transition/current") != 3:
			set("parameters/transition/current", 3)
			var playback:AnimationNodeStateMachinePlayback = get("parameters/attack_state_machine/playback")
			playback.start("FirstAttack")
			current_attack = 1
			_request_attack = 1
		elif is_attacking():
			var playback:AnimationNodeStateMachinePlayback = get("parameters/attack_state_machine/playback")
			var playback_current_node = playback.get_current_node()
			var last_attack:int = current_attack
			
			if "Idle" == playback_current_node:
				set("parameters/transition/current", 0)
				current_attack = 0
				_request_attack = 0
			elif "FirstAttack" == playback_current_node:
				current_attack = 1
			elif "SecondAttack" == playback_current_node:
				current_attack = 2
			elif "ThirdAttack" == playback_current_node:
				current_attack = 3
			if _request_attack < current_attack:
				playback.stop()
				set("parameters/transition/current", 0)
				current_attack = 0
				_request_attack = 0
		elif velocity == Vector3.ZERO:
			set("parameters/transition/current", 0)
		else:
			set("parameters/transition/current", 1)
			if is_braking:
				set("parameters/walk_and_brake_blend/blend_amount", 1)
			else:
				set("parameters/walk_and_brake_blend/blend_amount", 0)
				var horizontal_speed = (velocity - velocity.project(vertical_direction)).length()
				set("parameters/walking_speed/scale", horizontal_speed/5)
	else:
		_request_attack = 0
		set("parameters/transition/current", 2)
		var vertical_speed = velocity.dot(vertical_direction)
		set("parameters/in_air_blend/blend_amount", clamp(vertical_speed/10, -1, 1))
