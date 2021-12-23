class_name Bullet 
extends KinematicBody

const SPEED = 20

var main #: Main
var shooter

func _ready():
	main = get_tree().get_root().get_node("Main")
	pass


func _process(delta):
	var dir = global_transform.basis.z * delta * -1 * SPEED
	var col : KinematicCollision = move_and_collide(dir)
	if col:
		if col.collider != shooter:
			if col.collider.has_method("hit_by_bullet"):
				col.collider.hit_by_bullet()
				main.small_explosion(col.collider)
				if "SCORE" in col.collider:
					main.inc_score(col.collider.SCORE)
				self.queue_free()
			else:
				main.play_clang()
				main.tiny_explosion(self)
			queue_free()
	pass


func _on_Timer_timeout():
	queue_free()
	pass
