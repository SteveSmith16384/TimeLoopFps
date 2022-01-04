class_name Bullet 
extends Area

var BULLET_SPEED = 40#70

const KILL_TIMER = 4
var timer = 0
var hit_something = false
var shooter # to check who is a ghost

func _ready():
	pass


func _process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * BULLET_SPEED * delta * -1)

	timer += delta
	if timer >= KILL_TIMER:
		queue_free()

	pass



func _on_Bullet_body_entered(body):
	if hit_something:
		return
		
	if body.is_in_group("players"):
		if body.side == shooter.side:
			return
			
		if body.is_alive():
			if shooter.is_alive():
				body.bullet_hit(Globals.BULLET_DAMAGE)

			hit_something = true
			queue_free()
	else:
		hit_something = true
		queue_free()
	pass
