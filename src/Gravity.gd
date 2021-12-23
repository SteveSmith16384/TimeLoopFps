extends Node

const gravity = .7#.7
const jump_power = 7

var grav_offset = 0
var on_floor = false

func _physics_process(delta):
	if owner.translation.y < -10:
		print("Problem")
	
	grav_offset -= gravity
	var vec3 = Vector3.ZERO
	vec3.y = grav_offset
	owner.move_and_slide(vec3, Vector3.UP)
	if owner.get_slide_count() > 0:
		if vec3.y < 0:
			grav_offset = 0
			on_floor = true
	pass
	
	
func jump():
	if on_floor: 
		on_floor = false
		#$AudioStreamPlayer_Jump.play()
		grav_offset += jump_power
