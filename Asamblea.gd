extends Node2D

const DIALOGO = preload("res://Dialogos/dialogo.tscn")

var dialog_lines = RandomizedList.new([
		"Yo me equivoqué y pagué, pero la pelota no se mancha.",
		"barrilete cósmico, ¿de qué planeta viniste?",
		"Si querés llorar llorá",
		"El decorado se calla",
		"Me cortaron las piernas",
		"Que miseria che...3 empanadas",
		"Yo hago ravioles, ella hace ravioles",
		"Sos un fracasado, todos progresan menos vos",
		"Como te ven, te tratan. Si te ven mal, te maltratan. Si te ven bien, te contratan",
		"Anda pa' alla, bobo",
		"Basta, chicos",
	])
var partidos = []

func _process(delta):
	pass

func _ready():
	partidos = RandomizedList.new(%Dialogos.get_children())
	empezar_asamblea()

func empezar_asamblea():
	hacer_decir_dialogo_a_alguno()
	
func hacer_decir_dialogo_a_alguno():
	var config := %ConfiguracionDelJuego
	var partido = partidos.next()
	var representante = partido.get_children().pick_random()
	var dialogo = DIALOGO.instantiate()
	dialogo.tiempo_hasta_que_se_borra = config.tiempo_hasta_que_se_borra_burbuja_de_dialogo
	dialogo.velocidad_de_burbuja = config.velocidad_de_burbuja_de_dialogo
	dialogo.texto = dialog_lines.next()
	representante.add_child(dialogo)
	
	var mas_menos_tiempo_entre_dialogos =\
		config.mas_menos_tiempo_entre_dialogos
	var tiempo_hasta_proximo_dialogo =\
		config.tiempo_entre_dialogos + randf_range(
			-mas_menos_tiempo_entre_dialogos,
			mas_menos_tiempo_entre_dialogos)

	await get_tree().create_timer(tiempo_hasta_proximo_dialogo).timeout
	hacer_decir_dialogo_a_alguno()

class RandomizedList:
	var list: Array
	var used_elements: Array = []
	
	func _init(_list):
		list = _list
	
	func next():
		if list.is_empty():
			list = used_elements.duplicate()
			used_elements.clear()
		list.shuffle()
		var element = list.pop_front()
		used_elements.push_back(element)
		return element
