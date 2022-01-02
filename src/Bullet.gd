class_name Bullet 
extends Area

var BULLET_SPEED = 40#70
var BULLET_DAMAGE = 15

const KILL_TIMER = 4
var timer = 0
var hit_something = false
var side

func _ready():
#	main = get_tree().get_root().get_node("Main")
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
		if body.side == side:
			return
			
		if body.is_alive():
			body.bullet_hit(BULLET_DAMAGE)

			hit_something = true
			queue_free()
	else:
		hit_something = true
		queue_free()
	pass
