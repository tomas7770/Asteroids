extends Node

func _ready() -> void:
	randomize()

func WrapScreen(position: Vector2, width: float = 0.0, height: float = 0.0) -> Vector2:
	if position.x < -width:
		# Left border
		position.x = 800.0+width
	elif position.x > 800.0+width:
		# Right border
		position.x = -width
	if position.y < -height:
		# Top border
		position.y = 600.0+height
	elif position.y > 600.0+height:
		# Bottom border
		position.y = -height
	return position
