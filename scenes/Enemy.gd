extends Area2D
class_name Enemy

enum States {ALIVE, DEAD}

var CurrentState: int = States.ALIVE
var velocity: Vector2
var points: int

# warning-ignore:unused_signal
signal enemy_destroyed

func is_class(className: String) -> bool:
	return className == "Enemy" or .is_class(className)
