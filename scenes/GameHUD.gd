extends Control

onready var score_label := $ScoreLabel as Label
onready var lives_label := $LivesLabel as Label
onready var lives_texture := $LivesTexture as TextureRect
onready var level_label := $LevelLabel as Label
onready var gameover_popup := $GameoverPopup as PopupDialog
onready var pause_overlay := $PauseOverlay as ColorRect

func _ready() -> void:
	# warning-ignore:return_value_discarded
	get_tree().get_current_scene().connect("score_changed",self,"_on_score_changed")
	# warning-ignore:return_value_discarded
	get_tree().get_current_scene().connect("lives_changed",self,"_on_lives_changed")
	# warning-ignore:return_value_discarded
	get_tree().get_current_scene().connect("level_changed",self,"_on_level_changed")
	# warning-ignore:return_value_discarded
	get_tree().get_current_scene().connect("pause_toggled",self,"_on_pause_toggle")

func _on_score_changed(score: int) -> void:
	score_label.set_text(str("Score: ",score))

func _on_lives_changed(lives: int) -> void:
	if lives <= 4:
		lives_label.visible = false
		if lives == 0:
			lives_texture.visible = false
			gameover_popup.popup()
		else:
			lives_texture.set_size(Vector2(lives*32.0,32.0))
	else:
		lives_texture.set_size(Vector2(32.0,32.0))
		lives_label.visible = true
		lives_label.set_text(str("x",lives))

func _on_level_changed(level: int) -> void:
	level_label.set_text(str("Level ",level))

func _on_pause_toggle() -> void:
	pause_overlay.visible = get_tree().paused
