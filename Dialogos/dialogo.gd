@tool
class_name Dialogo
extends Control

var velocidad_de_burbuja := 0.0
var tiempo_hasta_que_se_borra := 10.0
var texto := ""
var _postura
var time_since_mouse_left = 5
var mouse_hovering = false
var borrandose = false
@export var reaccionable = true
@onready var text_label = %RichTextLabel

signal borrado
signal intervenido
signal fue_aprobado
signal fue_rechazado

func _ready():
	if reaccionable:
		%Intervenciones/DeAcuerdo.pressed.connect(self.reconfirmado)
		%Intervenciones/EnContra.pressed.connect(self.rechazado)
		%Intervenciones.get_children().map(func(boton): boton.visible = false)
		var hoverable_nodes = [text_label, %Intervenciones/DeAcuerdo, %Intervenciones/EnContra]
		hoverable_nodes.map(func(hoverable_node):
			hoverable_node.mouse_entered.connect(func(): mouse_hovering = true)
			hoverable_node.mouse_exited.connect(func(): mouse_hovering = false)
		)

	text_label.layout_mode = 1
	text_label.anchors_preset = PRESET_FULL_RECT
	var appear_tween = create_tween()
	appear_tween.tween_property(self, "modulate:a", 1.0, 0.2).from(0.0)
	if texto:
		text_label.text = texto

func _process(delta):
	if Engine.is_editor_hint():
		return
	if borrandose:
		return
	if not reaccionable:
		return
	time_since_mouse_left = 0 if mouse_hovering else time_since_mouse_left + delta
	var mouse_hovered_recently = time_since_mouse_left < 1.0
	if(not %Intervenciones/DeAcuerdo.visible and mouse_hovered_recently):
		mostrar_posibles_intervenciones(mouse_hovered_recently)
	if(%Intervenciones/DeAcuerdo.visible and not mouse_hovered_recently):
		esconder_intervenciones(mouse_hovered_recently)
	position.y -= delta * velocidad_de_burbuja
	text_label.modulate.r = 0.5 if mouse_hovered_recently else 1.0
	text_label.modulate.b = 0.5 if mouse_hovered_recently else 1.0
	text_label.modulate.g = 0.5 if mouse_hovered_recently else 1.0
	tiempo_hasta_que_se_borra -= delta
	if(tiempo_hasta_que_se_borra <= 0.0):
		self.paso_mucho_tiempo()

func realentizar():
	velocidad_de_burbuja = velocidad_de_burbuja / 2.0
	tiempo_hasta_que_se_borra = tiempo_hasta_que_se_borra * 2.0

func postura():
	return _postura

func mostrar_posibles_intervenciones(mouse_hovered_recently):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(%Intervenciones/DeAcuerdo, "scale", Vector2.ONE, 0.1).from(Vector2.ONE * 0.2)
	tween.tween_property(%Intervenciones/EnContra, "scale", Vector2.ONE, 0.1).from(Vector2.ONE * 0.2)
	%Intervenciones/DeAcuerdo.visible = mouse_hovered_recently
	%Intervenciones/EnContra.visible = mouse_hovered_recently

func esconder_intervenciones(mouse_hovered_recently):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(%Intervenciones/DeAcuerdo, "scale", Vector2.ZERO, 0.1)
	await tween.tween_property(%Intervenciones/EnContra, "scale", Vector2.ZERO, 0.1).finished
	%Intervenciones/DeAcuerdo.visible = mouse_hovered_recently
	%Intervenciones/EnContra.visible = mouse_hovered_recently

func borrarse():
	if(borrandose):
		return
	borrandose = true
	await create_tween().tween_property(self, "modulate:a", 0.0, 0.5).finished
	borrado.emit()
	queue_free()

func paso_mucho_tiempo():
	borrarse()

func reconfirmado():
	fue_aprobado.emit()
	intervenirse_con(Color.GREEN)
	

func rechazado():
	fue_rechazado.emit()
	intervenirse_con(Color.RED)
	

func intervenirse_con(color: Color):
	if(borrandose):
		return
	text_label.modulate = color
	intervenido.emit()
	borrarse()

