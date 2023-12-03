extends HSlider

const SILLAZOS = 0.0
const PAZ = 100.0
var animosidad = (SILLAZOS + PAZ) / 2.0

func _ready():
	min_value = SILLAZOS
	max_value = PAZ
	value = animosidad

func mejorar(cantidad):
	animosidad = move_toward(animosidad, PAZ, cantidad)
	create_tween()\
		.tween_property(self, "value", animosidad, 0.5)\
		.set_trans(Tween.TRANS_QUAD)

func empeorar(cantidad):
	animosidad = move_toward(animosidad, SILLAZOS, cantidad)
	create_tween()\
		.tween_property(self, "value", animosidad, 0.5)\
		.set_trans(Tween.TRANS_ELASTIC)

