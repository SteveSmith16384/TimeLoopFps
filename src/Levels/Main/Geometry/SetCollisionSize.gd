extends MeshInstance


func _ready():
	var mesh_size : AABB = self.get_aabb()
	var coll_shape : BoxShape = $StaticBody/CollisionShape.shape
	coll_shape.extents = mesh_size.size / 2
	pass
