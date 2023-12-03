extends Node

static func any(coroutines):
	var promise = Promise.new()
	for coroutine in coroutines:
		promise.wait_for(coroutine)
	await promise.finished_one

class Promise:
	signal finished_one

	func wait_for(coroutine):
		await coroutine
		finished_one.emit()
