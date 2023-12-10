extends Control

const ASAMBLEA_PATH = "res://Asamblea.tscn"

func _ready():
	ResourceLoader.load_threaded_request(ASAMBLEA_PATH)
	%Comenzar.pressed.connect(func():
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(ASAMBLEA_PATH)
		)
	)

func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(ASAMBLEA_PATH)
	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			%Comenzar.disabled = true
			%Comenzar.text = "Cargando..."
		ResourceLoader.THREAD_LOAD_LOADED:
			%Comenzar.disabled = false
			%Comenzar.text = "¡Empezar!"
