extends TextureProgressBar

signal tiempo_alcanzado

var original_scale

func _ready():
	original_scale = scale

var segundos_restantes: float = 0.0

func esta_esperando():
	return segundos_restantes > 0.0

func esperar(segundos):
	segundos_restantes = segundos
	max_value = segundos_restantes
	create_tween().tween_property(self, "scale", original_scale, 0.3).from(original_scale * 1.2).set_trans(Tween.TRANS_SPRING)

func _physics_process(delta):
	value = segundos_restantes
	if(segundos_restantes > 0):
		segundos_restantes = move_toward(segundos_restantes, 0, delta)
		if(segundos_restantes == 0):
			tiempo_alcanzado.emit()
