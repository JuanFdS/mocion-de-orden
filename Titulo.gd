extends Control

const ASAMBLEA_PATH = "res://Asamblea.tscn"

var load_progress = 0.0

func _ready():
	ResourceLoader.load_threaded_request(ASAMBLEA_PATH)
	%Comenzar.pressed.connect(func():
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(ASAMBLEA_PATH)
		)
	)
	%LoadUpdater.timeout.connect(self.update_load)

func update_load():
	var progress = []
	var load_status = ResourceLoader.load_threaded_get_status(ASAMBLEA_PATH, progress)
	load_progress = max(progress[0], load_progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			%Comenzar.disabled = true
			%Comenzar.text = "Cargando... %.2f" % (load_progress * 100.0)
		ResourceLoader.THREAD_LOAD_LOADED:
			%Comenzar.disabled = false
			%Comenzar.text = "¡Empezar!"
