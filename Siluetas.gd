@tool
extends Control

@export var siluetas := {}

const sprite_frames = {
	"res://AsambleaPorPartes/silueta1_spriteframes_base.tres": "res://AsambleaPorPartes/silueta1_spriteframes.tres",
	"res://AsambleaPorPartes/silueta2_spriteframes_base.tres": "res://AsambleaPorPartes/silueta2_spriteframes.tres",
	"res://AsambleaPorPartes/silueta3_spriteframes_base.tres": "res://AsambleaPorPartes/silueta3_spriteframes.tres",
	"res://AsambleaPorPartes/silueta4_spriteframes_base.tres": "res://AsambleaPorPartes/silueta4_spriteframes.tres"
}

var already_loaded_resources = []

func setear_spriteframes_base():
	for sprite_frame in sprite_frames.keys():
		var sprite_frame_full = sprite_frames[sprite_frame]
		siluetas[sprite_frame_full].map(func(silueta):
			get_node(NodePath(silueta)).sprite_frames = load(sprite_frame)
		)

func cargar_segun_silueta():
	siluetas.clear()
	get_children().map(func(silueta):
		var sprite_frame_path = silueta.sprite_frames.resource_path
		if(not siluetas.has(sprite_frame_path)):
			siluetas[sprite_frame_path] = []
		siluetas[sprite_frame_path].push_front(silueta.name)
	)

func _extend_inspector_begin(inspector):
	inspector.add_custom_control(
		CommonControls.new(inspector).method_button("cargar_segun_silueta")
	)
	inspector.add_custom_control(
		CommonControls.new(inspector).method_button("setear_spriteframes_base")
	)

func _ready():
	#get_children().map(func(silueta):
		#silueta.speed_scale = randf_range(0.6, 0.9)
		#silueta.flip_h = randf() > 0.5
		#silueta.scale = Vector2(randf_range(0.9, 1.1), randf_range(0.9, 1.1))
	#)
	if Engine.is_editor_hint():
		return
	for sprite_frame in sprite_frames.values():
		ResourceLoader.load_threaded_request(sprite_frame)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	for sprite_frame in (sprite_frames.values()):
		if(not sprite_frame in already_loaded_resources):
			var status = ResourceLoader.load_threaded_get_status(sprite_frame)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				already_loaded_resources.push_front(sprite_frame)
				var loaded_sprite_frame = ResourceLoader.load_threaded_get(sprite_frame)
				siluetas[sprite_frame].map(func(nombre_de_silueta):
					var silueta = get_node(NodePath(nombre_de_silueta))
					silueta.sprite_frames = loaded_sprite_frame
					silueta.call_deferred("play")
				)
		
	

func sillazos():
	get_children().map(func(silueta): silueta.play("Angry"))
