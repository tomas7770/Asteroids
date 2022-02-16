extends Area2D
class_name Player

const bullet_scene = preload("Bullet.tscn")
export var max_speed: float = 350.0
export var scalar_acceleration: float = 300.0
export(float,0,1) var friction: float = 0.2
export var angular_velocity: float = 180.0
export var shoot_rate: float = 4.0
var velocity: Vector2
var acceleration: Vector2
var in_hyper_space: bool
onready var collision_shape := $CollisionShape2D as CollisionShape2D
onready var shoot_timer := $ShootTimer as Timer
onready var ffield_timer := $FFieldTimer as Timer
onready var hyper_space_anim := $Hyperspace as AnimationPlayer
onready var respawn_anim := $Respawn as AnimationPlayer

signal hit_enemy

func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("area_entered",self,"_on_area_entered")
	# warning-ignore:return_value_discarded
	ffield_timer.connect("timeout",self,"_on_forcefield_ended")
	shoot_timer.set_wait_time(1.0/shoot_rate)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("player_accelerate"):
		acceleration = Vector2(0.0, -1.0).rotated(rotation)*scalar_acceleration
	if Input.is_action_pressed("player_left"):
		rotation_degrees -= angular_velocity*delta
	if Input.is_action_pressed("player_right"):
		rotation_degrees += angular_velocity*delta
	if Input.is_action_pressed("player_shoot") and shoot_timer.is_stopped():
		shoot_timer.start()
		var new_bullet := bullet_scene.instance() as Area2D
		get_tree().get_current_scene().add_child(new_bullet)
		new_bullet.position = position
		new_bullet.rotation = rotation
	# Position/velocity updates
	if not in_hyper_space:
		position += (velocity*delta+acceleration*0.5*pow(delta,2.0)).clamped(max_speed*delta)
		position = Global.WrapScreen(position,24.0,24.0)
		if acceleration.length() <= 0.0 and velocity.length() < 20.0:
			# Avoids overly slow deceleration at low speeds
			velocity.x = 0.0
			velocity.y = 0.0
		else:
			velocity += acceleration*delta
			velocity *= 1.0-(friction*delta)
			velocity = velocity.clamped(max_speed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_hyperspace") and not in_hyper_space:
		in_hyper_space = true
		collision_shape.disabled = true
		hyper_space_anim.play("Hyperspace")
	elif event.is_action_released("player_accelerate"):
		acceleration.x = 0.0
		acceleration.y = 0.0

func _on_area_entered(area: Area2D) -> void:
	if area.is_class("Enemy") and area.CurrentState == area.States.ALIVE:
		emit_signal("hit_enemy")
		queue_free()

func _on_forcefield_ended() -> void:
	respawn_anim.stop()
	collision_shape.disabled = false

func _on_HyperSpace_timeout(phase: int) -> void:
	if phase == 0:
		position.x = randi()%801
		position.y = randi()%601
	elif phase == 1:
		in_hyper_space = false
		if ffield_timer.is_stopped():
			collision_shape.disabled = false

func is_class(className: String) -> bool:
	return className == "Player" or .is_class(className)
	
func trigger_forcefield() -> void:
	respawn_anim.play("Respawn")
	collision_shape.disabled = true
	ffield_timer.start()
