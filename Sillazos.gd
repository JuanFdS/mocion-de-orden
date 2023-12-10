extends CanvasLayer


# Called when the node enters the scene tree for the first time.

func activar():
	visible = true
	%Siluetas.sillazos()
	%SillazosAnimados.visible = true
	%Dialogos.get_children().map(func(delegado): delegado.sillazos())
	$AnimationPlayer.play("sillazos")
	#for emitter in get_children():
		#if emitter is CPUParticles2D:
			#emitter.restart()
			#await get_tree().create_timer(1.5).timeout
