extends CanvasLayer


# Called when the node enters the scene tree for the first time.

func _ready():
	visible = false

func activar():
	visible = true
	%Siluetas.sillazos()
	%SillazosAnimados.visible = true
	%Dialogos.get_children().map(func(delegado): delegado.sillazos())
	$AnimationPlayer.play("sillazos")
	%Reintentar.pressed.connect(func():
		await create_tween().tween_property(%FadeOut, "color:a", 1.0, 0.5).finished
		await %Timer.espera_corta()
		get_tree().reload_current_scene()
	)

