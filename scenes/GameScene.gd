extends Control

const asteroid_scene = preload("Asteroid.tscn")
const player_scene = preload("Player.tscn")
var score: int = 0
var level: int = 1
var lives: int = 3
var _enemy_count: int
var _score_to_life: int
onready var player := $Player as Player
onready var respawn_timer := $RespawnTimer as Timer
onready var pause_handler := $PauseHandler as Node
onready var hud := $HUDLayer.get_node("GameHUD") as Control
onready var viewport := get_viewport()

signal score_changed
signal lives_changed
signal level_changed
signal pause_toggled

func _ready() -> void:
	# warning-ignore:return_value_discarded
	viewport.connect("size_changed", self, "_window_resize")
	_window_resize()
	# warning-ignore:return_value_discarded
	pause_handler.connect("pause_toggled",self,"_on_pause_toggle")
	# warning-ignore:return_value_discarded
	pause_handler.connect("manual_restart",self,"_on_manual_restart")
	# warning-ignore:return_value_discarded
	respawn_timer.connect("timeout",self,"_on_respawned")
	# warning-ignore:return_value_discarded
	player.connect("hit_enemy",self,"_on_player_died")
	emit_signal("score_changed",score)
	emit_signal("lives_changed",lives)
	emit_signal("level_changed",level)
	_start_level()

func _window_resize() -> void:
	hud.set_size(viewport.get_visible_rect().size)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and lives <= 0:
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()

func _on_pause_toggle() -> void:
	emit_signal("pause_toggled")

func _on_manual_restart() -> void:
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _on_enemy_hit(enemy: Enemy) -> void:
	# Enemy was hit by bullet
	if lives > 0:
		score += enemy.points
		_score_to_life += enemy.points
		if _score_to_life >= 20000:
			lives += 1
			emit_signal("lives_changed",lives)
			_score_to_life -= 20000
		emit_signal("score_changed",score)

func _on_enemy_destroyed() -> void:
	# Enemy was destroyed (doesn't matter how)
	_enemy_count -= 1
	if _enemy_count <= 0:
		# New level!
		level += 1
		emit_signal("level_changed",level)
		call_deferred("_start_level")

func _on_player_died() -> void:
	lives -= 1
	emit_signal("lives_changed",lives)
	if lives > 0:
		respawn_timer.start()

func _on_respawned() -> void:
	var new_player := player_scene.instance() as Player
	add_child(new_player)
	player = new_player
	player.position = Vector2(400.0,300.0)
	player.trigger_forcefield()
	# warning-ignore:return_value_discarded
	player.connect("hit_enemy",self,"_on_player_died")

func _level_asteroid_count(desired_level: int) -> int:
	return 2+(2*desired_level)

func _start_level() -> void:
	var asteroid_count := _level_asteroid_count(level)
	_enemy_count = asteroid_count*7
	for i in asteroid_count:
		var new_asteroid := asteroid_scene.instance() as Asteroid
		add_child(new_asteroid)
		# Funny way to spawn at random corner
		var corner: int = randi()%2
		if corner == 0:
			# Top/Bottom
			new_asteroid.position.x = randi()%800
			new_asteroid.position.y = -(new_asteroid.height)
		elif corner == 1:
			# Left/Right
			new_asteroid.position.x = -(new_asteroid.width)
			new_asteroid.position.y = randi()%600

func add_child(node: Node, legible_unique_name: bool = false) -> void:
	.add_child(node,legible_unique_name)
	if node.is_class("Bullet"):
		# warning-ignore:return_value_discarded
		node.connect("hit_enemy",self,"_on_enemy_hit")
	elif node.is_class("Enemy") and node.CurrentState == node.States.ALIVE:
		# warning-ignore:return_value_discarded
		node.connect("enemy_destroyed",self,"_on_enemy_destroyed")
