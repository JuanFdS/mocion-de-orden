extends Control

func _ready():
	get_children().map(func(silueta):
		silueta.frame = randi_range(0, 20)
		silueta.speed_scale = randf_range(0.6, 0.9)
		silueta.flip_h = randf() > 0.5
		silueta.scale = Vector2(randf_range(0.9, 1.1), randf_range(0.9, 1.1))
	)

func sillazos():
	get_children().map(func(silueta): silueta.play("Angry"))
