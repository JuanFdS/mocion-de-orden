extends TextureProgressBar

signal tiempo_alcanzado

var segundos_restantes: float = 0.0

func esta_esperando():
	return segundos_restantes > 0.0

func esperar(segundos):
	segundos_restantes = segundos
	max_value = segundos_restantes
	create_tween().tween_property(self, "scale", Vector2.ONE * 0.6, 0.3).from(Vector2.ONE * 0.9).set_trans(Tween.TRANS_SPRING)

func _physics_process(delta):
	value = segundos_restantes
	if(segundos_restantes > 0):
		segundos_restantes = move_toward(segundos_restantes, 0, delta)
		if(segundos_restantes == 0):
			tiempo_alcanzado.emit()
