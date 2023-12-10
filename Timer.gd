extends Node

const TIEMPO_CORTO = 0.5
const TIEMPO_LARGO = 3.0

func espera_corta():
	await get_tree().create_timer(TIEMPO_CORTO).timeout

func espera_larga():
	await get_tree().create_timer(TIEMPO_LARGO).timeout
