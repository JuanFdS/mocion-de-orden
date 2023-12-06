extends Node2D

const DIALOGO = preload("res://Dialogos/dialogo.tscn")

const VIOLETA = "Violeta"
const ROJO = "Rojo"
const CELESTE = "Celeste"

var dialog_lines = RandomizedList.new([
		#"Yo me equivoqué y pagué, pero la pelota no se mancha.",
		#"barrilete cósmico, ¿de qué planeta viniste?",
		#"Si querés llorar llorá",
		"El decorado se calla",
		#"Me cortaron las piernas",
		#"Que miseria che...3 empanadas",
		"Yo hago ravioles, ella hace ravioles",
		"Sos un fracasado, todos progresan menos vos",
		"Como te ven, te tratan. Si te ven mal, te maltratan. Si te ven bien, te contratan",
		"Anda pa' alla, bobo",
		#"Basta, chicos",
		"Usted se tiene que arrepentir de lo que dijo"
	])
var partidos = []
var dialogos_en_curso = []
var sillazos = false

var porotos_por_postura = {
	VIOLETA: 0,
	ROJO: 0,
	CELESTE: 0
}

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

func postura_ganadora():
	var posturas = porotos_por_postura.keys()
	posturas.sort_custom(func(una_postura, otra_postura):
		return porotos_por_postura[una_postura] > porotos_por_postura[otra_postura]
	)
	return posturas.front()

func dar_resultado_final():
	if sillazos:
		return
	if Dialogic.current_timeline != null:
		return
	var postura = {VIOLETA: "[color=purple]Violeta[/color]",
					ROJO: "[color=red]Rojo[/color]",
					CELESTE: "[color=cyan]Celeste[/color]"}[postura_ganadora()]
	Dialogic.VAR.propuesta_ganadora = postura
	Dialogic.start('anunciarGanador')

func crear_dialogo():
	var config := %ConfiguracionDelJuego
	var partido = partidos.next()
	var representante = partido.get_children().pick_random()
	var dialogo = DIALOGO.instantiate()
	dialogo.tiempo_hasta_que_se_borra = config.tiempo_hasta_que_se_borra_burbuja_de_dialogo
	dialogo.velocidad_de_burbuja = config.velocidad_de_burbuja_de_dialogo
	dialogo.texto = dialog_lines.next()
	dialogo._postura = partido.name
	representante.add_child(dialogo)
	
	dialogos_en_curso.push_front(dialogo)
	dialogo.fue_aprobado.connect(func():
		sumar_poroto_a(dialogo.postura())
	)
	dialogo.fue_rechazado.connect(func():
		restar_poroto_a(dialogo.postura())
		restar_poroto_a(dialogo.postura())
	)
	dialogo.intervenido.connect(func():
		self.dialogo_fue_intervenido()
		dialogos_en_curso.map(func(un_dialogo): un_dialogo.borrarse())
	)
	dialogo.borrado.connect(func():
		sumar_poroto_a(dialogo.postura())
		dialogos_en_curso.erase(dialogo)
	)

	return dialogo

func restar_poroto_a(postura):
	porotos_por_postura[postura] -= 1

func sumar_poroto_a(postura):
	porotos_por_postura[postura] += 1

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
	
	if(dialog_lines.has_gone_through_all_elements()):
		dialogos_en_curso.map(func(dialogo): dialogo.borrarse())
		await get_tree().create_timer(0.5).timeout
		dar_resultado_final()
	else:
		hacer_decir_dialogo_a_alguno()

class RandomizedList:
	var list: Array
	var used_elements: Array = []
	
	func has_gone_through_all_elements():
		return list.is_empty()
	
	func _init(_list):
		list = _list
	
	func next():
		if has_gone_through_all_elements():
			list = used_elements.duplicate()
			used_elements.clear()
		list.shuffle()
		var element = list.pop_front()
		used_elements.push_back(element)
		return element
