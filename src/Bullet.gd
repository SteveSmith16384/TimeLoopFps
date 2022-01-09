class_name Bullet 
extends Area

var BULLET_SPEED = 40#70

const KILL_TIMER = 4
var timer = 0
var hit_something = false
var shooter

func _ready():
	$CSGCylinder.material.albedo_color = Globals.colors[shooter.side]
	if shooter.is_alive() == false:
		$CSGCylinder.material.albedo_color = $CSGCylinder.material.albedo_color.darkened(0.7)
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
			var main = get_tree().get_root().get_node("Main")
			main.small_explosion(self)
			queue_free()
	else:
		hit_something = true
		var main = get_tree().get_root().get_node("Main")
		main.tiny_explosion(self)
		queue_free()
	pass
	
