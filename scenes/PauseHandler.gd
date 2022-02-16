extends Node

signal pause_toggled
signal manual_restart

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Pause
		get_tree().paused = !(get_tree().paused)
		emit_signal("pause_toggled")
	elif event.is_action_pressed("ui_accept") and get_tree().paused:
		get_tree().paused = false
		emit_signal("manual_restart")
