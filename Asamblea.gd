extends Node2D

const DIALOGO = preload("res://Dialogos/dialogo.tscn")

const VIOLETA = "Violeta"
const ROJO = "Rojo"
const CELESTE = "Celeste"

var dialogos_de_acuerdo = RandomizedList.new(
	[func(partido): return 'Me parece acertada la postura %s' % ("de la compañera" if es_mujer(partido) else "del compañero"),
	 func(partido): return 'Lo que mencionó %s me parece que es una buena idea.' % (le_companiere(partido)),
	func(partido): return 'Estoy de acuerdo con lo que propuso %s.' % (le_companiere(partido))]
)

var dialogos_en_contra = RandomizedList.new(
	[
		func(partido): return ("%s, con todo respeto, no creo que sea una buena idea." % companiere(partido).capitalize()), 
	func(partido): return "Permitime diferir con vos, yo lo veo de otro modo.",
	func(partido): return ("Me parece que no va por ahí el tema, %s." % companiere(partido))]
)

var dialog_lines = RandomizedList.new([])

var dialogos_agendados = []

var partidos = []
var dialogos_en_curso = []
var sillazos = false

var porotos_por_postura = {
	VIOLETA: 0,
	ROJO: 0,
	CELESTE: 0
}

func es_mujer(partido):
	return partido == ROJO

func le_companiere(partido):
	return "la compañera" if es_mujer(partido) else "el compañero"

func companiere(partido):
	return "compañera" if es_mujer(partido) else "compañero"

func _ready():
	%Animosidad.sillazos_alcanzados.connect(func():
		if(not sillazos):
			sillazos = true
			%Sillazos.activar()
	)
	partidos = RandomizedList.new(%Dialogos.get_children())
	empezar_asamblea()

func empezar_asamblea():
	await %Tutorial.empezar()
	await decir('comienzoDeLaAsamblea')
	# dialogos guionados en orden:
	await presentar_propuestas()
	# esto solo se usaria si vamos por el flujo de tener dialogos random:
	#hacer_decir_dialogo_a_alguno()
	await %Timer.espera_corta()
	dar_resultado_final()

func agendar_dialogo(partido, linea):
	dialogos_agendados.push_back(DialogoAgendado.new(partido, linea))

func agendar_pausa():
	dialogos_agendados.push_back(Pausa.new())

class DialogoAgendado:
	signal terminado
	var _partido
	var _linea
	
	func _init(partido, linea):
		_partido = partido
		_linea = linea
	
	func reproducir_en(asamblea):
		var dialogo = asamblea.crear_dialogo(_partido, _linea)
		dialogo.borrado.connect(func(): terminado.emit())
		await Await.any([
			asamblea.espera_hasta_proximo_dialogo(),
			dialogo.borrado]
		)

class Pausa:
	signal terminado
	
	func reproducir_en(asamblea):
		await asamblea.espera_larga()
		terminado.emit()

func espera_corta():
	return %Timer.espera_corta()

func espera_larga():
	return %Timer.espera_larga()

func reproducir_dialogos_agendados():
	var ultimo_dialogo
	for dialogo_agendado in dialogos_agendados:
		if not sillazos:
			ultimo_dialogo = dialogo_agendado
			await dialogo_agendado.reproducir_en(self)
	await Await.any([ultimo_dialogo.terminado, %Timer.espera_larga()])

func presentar_propuestas():
	agendar_dialogo(
		%Violeta,
		"Mi papá tiene una carnicería y mi tía una librería. Proponemos la realización de una rifa en la cual sortearemos libros y una pata de ternera."
	)
	agendar_dialogo(
		%Rojo,
		"Pero tu tia vende puro best sellers."
	)
	agendar_dialogo(
		%Celeste,
		"Compa, pensemos en quienes son vegetarianes o veganes."
	)
	agendar_pausa()
	agendar_dialogo(
		%Rojo,
		"Podemos realizar una choripaneada abierta para toda la comunidad de la facu."
	)
	agendar_dialogo(
		%Violeta,
		"No me convence, porque la última vez que hicimos algo así tuvimos lío con el Decano."
	)
	agendar_dialogo(
		%Celeste,
		"Ah, vos tampoco pensás en les compañeres vegetarianes."
	)
	agendar_pausa()
	agendar_dialogo(
		%Celeste,
		"Realicemos una feria en el patio de la facu, no solo juntaremos el dinero necesario sino que también ayudaremos a emprendedores a difundir sus negocios, a cambio de que elles paguen una pequeña suma para poner su stand."
	)
	agendar_dialogo(
		%Violeta,
		"No creo que se pueda, el patio de la facu es muy chico para eso."
	)
	agendar_dialogo(
		%Rojo,
		"¿Con qué criterio vamos a elegir a les emprendedores que van a participar de la feria?"
	)
	
	await reproducir_dialogos_agendados()


func postura_ganadora():
	var posturas = porotos_por_postura.keys()
	posturas.sort_custom(func(una_postura, otra_postura):
		return porotos_por_postura[una_postura] > porotos_por_postura[otra_postura]
	)
	return posturas.front()

func decir(dialogo):
	Dialogic.start(dialogo)
	await Dialogic.timeline_ended

func dar_resultado_final():
	if sillazos:
		return
	
	var postura = {VIOLETA: "rifa de libros y una pata de ternera.",
					ROJO: "choripaneada abierta para toda la comunidad de la facu",
					CELESTE: "feria en el patio de la facu"}[postura_ganadora()]
	Dialogic.VAR.votos_rojo = str(max(0, porotos_por_postura[ROJO]))
	Dialogic.VAR.votos_violeta = str(max(0, porotos_por_postura[VIOLETA]))
	Dialogic.VAR.votos_celeste = str(max(0, porotos_por_postura[CELESTE]))
	Dialogic.VAR.propuesta_ganadora = postura
	await decir('anunciarGanador')
	animar_ganador()

func animar_ganador():
	{
		VIOLETA: %Violeta,
		ROJO: %Rojo,
		CELESTE: %Celeste
	}[postura_ganadora()].gano()

func crear_dialogo(partido, linea, reaccionable = true):
	var config := %ConfiguracionDelJuego
	var dialogo = DIALOGO.instantiate()
	dialogo.tiempo_hasta_que_se_borra = config.tiempo_hasta_que_se_borra_burbuja_de_dialogo
	dialogo.velocidad_de_burbuja = config.velocidad_de_burbuja_de_dialogo
	dialogo.texto = linea
	dialogo._postura = partido.name
	dialogo.reaccionable = reaccionable
	partido.agregar_dialogo(dialogo)
	

	if reaccionable:
		dialogos_en_curso.push_front(dialogo)
		dialogo.fue_aprobado.connect(func():
			estar_de_acuerdo(dialogo)
		)
		dialogo.fue_rechazado.connect(func():
			estar_en_contra(dialogo)
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

func estar_de_acuerdo(dialogo):
	Dialogic.VAR.de_acuerdo = dialogos_de_acuerdo.next().call(dialogo.postura())
	decir("acordar")
	sumar_poroto_a(dialogo.postura())

func estar_en_contra(dialogo):
	Dialogic.VAR.en_contra = dialogos_en_contra.next().call(dialogo.postura())
	decir("enContra")
	restar_poroto_a(dialogo.postura())

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

func espera_hasta_proximo_dialogo():
	var tiempo_hasta_proximo_dialogo = obtener_tiempo_hasta_proximo_dialogo()
	return get_tree().create_timer(tiempo_hasta_proximo_dialogo).timeout

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
