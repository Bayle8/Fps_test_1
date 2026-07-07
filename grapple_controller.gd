extends Node

@export var ray: RayCast3D
@export var rope: Node3D
@export var rest_length = 2.0
@export var stiffness = 10.0
@export var damping_coefficient = 1.0

@onready var player: CharacterBody3D = get_parent()

var launched = false
var target = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Grapple"):
		launch()
	if Input.is_action_just_released("Grapple"):
		retract()
	if launched:
		handle_grapple(delta)
		
	update_rope()
		
func launch() -> void:
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true
	
func retract() -> void:
	launched = false
	
func handle_grapple(delta: float) -> void:
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	var displacement = target_dist - rest_length
	var force = Vector3.ZERO    
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damping_force = target_dir * (-damping_coefficient * vel_dot) # Rinominata la variabile locale
		
		force = spring_force + damping_force
		
	player.velocity += force * delta

func update_rope():
	if !launched:
		rope.visible = false
		return
	
	rope.visible = true
	var dist = player.global_position.distance_to(target)
	rope.look_at(target)
	rope.scale = Vector3(1, 1, dist)
