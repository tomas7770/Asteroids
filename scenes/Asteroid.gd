extends Enemy
class_name Asteroid

export var speed: float = 50.0
export var base_points: int = 100
var _died: bool = false
var _clones_left: int = 2 # How many more times the asteroid will break itself when hit
var width: float = 60.0
var height: float = 60.0
onready var asteroid_scene := load("scenes/Asteroid.tscn")

func _ready() -> void:
	points = base_points
	# warning-ignore:return_value_discarded
	connect("area_entered",self,"_on_area_entered")
	velocity = Vector2(1.0, 0.0).rotated(randf()*2*PI)*speed

func _physics_process(delta: float) -> void:
	if _died and CurrentState == States.ALIVE:
		CurrentState = States.DEAD
		set_physics_process(false)
		return
	position += velocity*delta
	position = Global.WrapScreen(position,width,height)

func _on_area_entered(area: Area2D) -> void:
	if _died and CurrentState == States.ALIVE:
		CurrentState = States.DEAD
		set_physics_process(false)
	elif CurrentState == States.ALIVE and (area.is_class("Bullet") or area.is_class("Player")):
		if _clones_left > 0:
			call_deferred("_clone_asteroid")
		_died = true
		emit_signal("enemy_destroyed")
		queue_free()

func _clone_asteroid() -> void:
	for i in 2:
		var new_asteroid := asteroid_scene.instance() as Asteroid
		get_parent().add_child(new_asteroid)
		new_asteroid.position = position
		new_asteroid.velocity = velocity.rotated(randf()*2*PI)*2
		new_asteroid.points = points*2
		new_asteroid._clones_left = _clones_left - 1
		new_asteroid.width = width*0.5
		new_asteroid.height = height*0.5
		new_asteroid.set_scale(Vector2(scale.x*0.5,scale.y*0.5))
