extends Area2D
class_name Bullet

export var speed: float = 500.0
var velocity: Vector2
var removal_timer: Timer

signal hit_enemy

func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("area_entered",self,"_on_area_entered")
	removal_timer = $RemovalTimer as Timer
	# warning-ignore:return_value_discarded
	removal_timer.connect("timeout",self,"_on_removal_timeout")

func _physics_process(delta: float) -> void:
	velocity = Vector2(0.0, -1.0).rotated(rotation)*speed
	position += velocity*delta
	position = Global.WrapScreen(position,12.0,12.0)

func _on_removal_timeout() -> void:
	# Self destruct
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_class("Enemy") and area.CurrentState == area.States.ALIVE:
		emit_signal("hit_enemy",area)
		queue_free()

func is_class(className: String) -> bool:
	return className == "Bullet" or .is_class(className)
