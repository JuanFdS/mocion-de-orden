extends CanvasLayer

@onready var titulo = $Contenido/Titulo
@onready var descripcion = $Contenido/Descripcion
@onready var asamblea = get_parent()
@onready var reintentar = $Contenido/Reintentar

func _ready():
	descripcion.visible_characters = 0
	titulo.visible_characters = 0
	$Contenido.modulate.a = 0.0
	$Contenido.visible = false
	reintentar.visible = false
	reintentar.pressed.connect(func():
		get_tree().reload_current_scene()
	)

func mostrar_resultado(postura):
	titulo.text = "[center]Propuesta ganadora: %s[/center]" % asamblea.propuesta_ganadora()
	descripcion.text = texto_de_descripcion(postura)

	$Contenido.visible = true
	await create_tween().tween_property(
		$Contenido,
		"modulate:a",
		1.0,
		0.5
	).finished

	create_tween().tween_property(
		titulo,
		"visible_characters",
		descripcion.get_total_character_count(),
		descripcion.get_total_character_count() / 25.0
	)

	await %Timer.espera_larga()

	await create_tween().tween_property(
		descripcion,
		"visible_characters",
		descripcion.get_total_character_count(),
		descripcion.get_total_character_count() / 25.0
	).finished

	reintentar.visible = true

func texto_de_descripcion(postura):
	return {
		"Rojo": "El evento fue un desastre, hubo gente que se agarró a las piñas, la facultad quedó sucia y el decano prohibió la realización de eventos en el patio. Intentá de nuevo con otra idea. ",
		"Celeste": "La iniciativa tuvo un éxito moderado, si bien recaudaron bastante dinero, no alcanzó para financiar el viaje de todes les compañeres. Intentá de nuevo para juntar más fondos.",
		"Verde": "La feria tuvo un éxito rotundo, se recaudó todo el dinero necesario y les asistentes disfrutaron enormemente del evento, además de ayudar a les emprendedores que expusieron. Nuevamente, quedó demostrado que la salida es colectiva."
	}[postura]
