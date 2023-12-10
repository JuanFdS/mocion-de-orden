extends CanvasLayer

@onready var pasos = $Control/Pasos.get_children()
# Called when the node enters the scene tree for the first time.

var paso_actual
var cambiando_de_paso = false

signal terminado

func _ready():
	visible = false
	for paso in pasos:
		paso.modulate.a = 0.0
	%TutoSiguiente.pressed.connect(self.adelante)
	%TutoAnterior.pressed.connect(self.atras)

func empezar():
	visible = true
	paso_actual = pasos.front()
	mostrar_paso(paso_actual)
	await self.terminado

func _process(_delta):
	%TutoAnterior.disabled = en_primer_paso() or cambiando_de_paso
	%TutoSiguiente.disabled = cambiando_de_paso
	%TutoSiguiente.text = "Comenzar" if en_ultimo_paso() else "Siguiente"

func en_primer_paso():
	return pasos.find(paso_actual) == 0

func en_ultimo_paso():
	return pasos.find(paso_actual) == (pasos.size() - 1)

func mostrar_paso(paso):
	paso.visible = true
	await create_tween().tween_property(paso, "modulate:a", 1.0, 0.5).finished

func esconder_paso(paso):
	await create_tween().tween_property(paso, "modulate:a", 0.0, 0.5).finished	
	paso.visible = false

func adelante():
	var idx = pasos.find(paso_actual)
	
	if(cambiando_de_paso):
		return

	if(en_ultimo_paso()):
		queue_free()
		terminado.emit()
		return

	await transicionar_a(pasos[idx + 1])

func atras():
	var idx = pasos.find(paso_actual)

	if(en_primer_paso() or cambiando_de_paso):
		return

	await transicionar_a(pasos[idx - 1])

func transicionar_a(nuevo_paso):
	cambiando_de_paso = true
	await esconder_paso(paso_actual)
	paso_actual = nuevo_paso
	await mostrar_paso(paso_actual)
	cambiando_de_paso = false
