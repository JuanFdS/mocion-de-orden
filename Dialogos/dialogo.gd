@tool
extends RichTextLabel

var velocidad_de_burbuja
var tiempo_hasta_que_se_borra
var texto

func _ready():
	layout_mode = 1
	anchors_preset = PRESET_FULL_RECT
	text = texto
	get_tree().create_timer(tiempo_hasta_que_se_borra).timeout.connect(self.borrarse)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	position.y -= delta * velocidad_de_burbuja

func borrarse():
	await create_tween().tween_property(self, "modulate:a", 0.0, 0.5).finished
	queue_free()
