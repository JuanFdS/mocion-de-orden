extends Control

var dialogos_en_curso = []

func sillazos():
	$Delegado.play("HyperAngry")

func agregar_dialogo(dialogo: Dialogo):
	dialogos_en_curso.push_front(dialogo)
	$Posicion.add_child(dialogo)
	$Delegado.play("Talking")
	var terminar_de_hablar = func(): self.terminar_dialogo(dialogo)
	dialogo.borrado.connect(terminar_de_hablar)
	dialogo.intervenido.connect(func(): dialogo.borrado.disconnect(terminar_de_hablar))
	dialogo.fue_aprobado.connect(func(): self.ponerse_contente())
	dialogo.fue_rechazado.connect(func(): self.enojarse())

func ponerse_contente():
	hacer_animacion_y_volver_a_idle("Happy")

func enojarse():
	hacer_animacion_y_volver_a_idle("Angry")

func hacer_animacion_y_volver_a_idle(animation):
	$Delegado.play(animation)
	$Delegado.animation_finished.connect(func():
		if $Delegado.animation == animation:
			$Delegado.play("Idle")
	)

func terminar_dialogo(dialogo):
	dialogos_en_curso.erase(dialogo)
	if dialogos_en_curso.is_empty():
		$Delegado.play("Idle")
