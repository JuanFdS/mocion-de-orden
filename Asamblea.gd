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
	await decir('comienzoDeLaAsamblea')
	await presentar_propuestas()
	hacer_decir_dialogo_a_alguno()

func presentar_propuestas():
	crear_dialogo(%Violeta,
					"Mi papá tiene una carnicería y mi tía una librería. Proponemos la realización de una rifa en la cual sortearemos libros y una pata de ternera.",
					false).realentizar()
	await %Timer.espera_larga()
	crear_dialogo(%Rojo,
					"Pero tu tía tiene vende puro best sellers.",
					false).realentizar()
	await %Timer.espera_larga()
	var respuesta = crear_dialogo(%Celeste,
					"Compa, pensemos en quienes son vegetarianes o veganes.",
					false)
	respuesta.realentizar()
	await respuesta.borrado
	
	crear_dialogo(%Rojo,
		"Podemos realizar una choripaneada abierta para toda la comunidad de la facu.",
		false).realentizar()
	await %Timer.espera_larga()
	crear_dialogo(%Violeta,
		"No me convence, porque la última vez que hicimos algo así tuvimos lío con el Decano.",
		false).realentizar()
	await %Timer.espera_larga()
	respuesta = crear_dialogo(%Celeste,
		"Ah, vos tampoco pensás en les compañeres vegetarianes.", false)
	respuesta.realentizar()
	await respuesta.borrado
	
	crear_dialogo(%Celeste,
		"Podemos realizar una feria en el patio de la facu, donde no solo podremos juntar el dinero necesario sino también ayudar a emprendedores a difundir sus negocios y tener más ventas, a cambio de que elles paguen una pequeña suma para poner su stand.",
		false).realentizar()
	await %Timer.espera_larga()
	crear_dialogo(%Violeta,
		"No creo que se pueda, el patio de la facu es muy chico para eso.",
		false).realentizar()
	await %Timer.espera_larga()
	respuesta = crear_dialogo(%Rojo,
		"¿Con qué criterio vamos a elegir a les emprendedores que van a participar de la feria?", false)
	respuesta.realentizar()
	await respuesta.borrado


func postura_ganadora():
	var posturas = porotos_por_postura.keys()
	posturas.sort_custom(func(una_postura, otra_postura):
		return porotos_por_postura[una_postura] > porotos_por_postura[otra_postura]
	)
	return posturas.front()

func decir(dialogo):
	if Dialogic.current_timeline != null:
		return
	Dialogic.start(dialogo)
	await Dialogic.timeline_ended

func dar_resultado_final():
	if sillazos:
		return
	
	var postura = {VIOLETA: "[color=purple]Violeta[/color]",
					ROJO: "[color=red]Rojo[/color]",
					CELESTE: "[color=cyan]Celeste[/color]"}[postura_ganadora()]
	Dialogic.VAR.propuesta_ganadora = postura
	await decir('anunciarGanador')

func crear_dialogo(partido, linea, reaccionable = true):
	var config := %ConfiguracionDelJuego
	var representante = partido.get_children().pick_random()
	var dialogo = DIALOGO.instantiate()
	dialogo.tiempo_hasta_que_se_borra = config.tiempo_hasta_que_se_borra_burbuja_de_dialogo
	dialogo.velocidad_de_burbuja = config.velocidad_de_burbuja_de_dialogo
	dialogo.texto = linea
	dialogo._postura = partido.name
	dialogo.reaccionable = reaccionable
	representante.add_child(dialogo)
	

	if reaccionable:
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
	
	var dialogo = crear_dialogo(partidos.next(), dialog_lines.next())
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
