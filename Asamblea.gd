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
		"Usted se tiene que arrepentir de lo que dijo"
	])
var partidos = []
var dialogos_en_curso = []
var sillazos = false

func _ready():
	%Animosidad.sillazos_alcanzados.connect(func():
		if(not sillazos):
			sillazos = true
			%Sillazos.activar()
	)
	partidos = RandomizedList.new(%Dialogos.get_children())
	empezar_asamblea()

func empezar_asamblea():
	hacer_decir_dialogo_a_alguno()

func crear_dialogo():
	var config := %ConfiguracionDelJuego
	var partido = partidos.next()
	var representante = partido.get_children().pick_random()
	var dialogo = DIALOGO.instantiate()
	dialogo.tiempo_hasta_que_se_borra = config.tiempo_hasta_que_se_borra_burbuja_de_dialogo
	dialogo.velocidad_de_burbuja = config.velocidad_de_burbuja_de_dialogo
	dialogo.texto = dialog_lines.next()
	representante.add_child(dialogo)
	
	dialogos_en_curso.push_front(dialogo)
	dialogo.intervenido.connect(func():
		self.dialogo_fue_intervenido()
		dialogos_en_curso.map(func(un_dialogo): un_dialogo.borrarse())
	)
	dialogo.borrado.connect(func(): dialogos_en_curso.erase(dialogo))
	
	return dialogo

func dialogo_fue_intervenido():
	var reloj = %Reloj
	if(reloj.esta_esperando()):
		%Animosidad.empeorar(20)
	reloj.esperar(5)

func obtener_tiempo_hasta_proximo_dialogo():
	var config := %ConfiguracionDelJuego
	var mas_menos_tiempo_entre_dialogos =\
		config.mas_menos_tiempo_entre_dialogos
	var tiempo_hasta_proximo_dialogo =\
		config.tiempo_entre_dialogos + randf_range(
			-mas_menos_tiempo_entre_dialogos,
			mas_menos_tiempo_entre_dialogos)

	return tiempo_hasta_proximo_dialogo

func hacer_decir_dialogo_a_alguno():
	if(sillazos):
		return
	var config := %ConfiguracionDelJuego
	
	var dialogo = crear_dialogo()
	var tiempo_hasta_proximo_dialogo = obtener_tiempo_hasta_proximo_dialogo()

	await Await.any([
		dialogo.borrado,
		get_tree().create_timer(tiempo_hasta_proximo_dialogo).timeout
	])
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
