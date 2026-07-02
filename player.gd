extends CharacterBody3D

#variabili comuni
var speed 
const WALK_SPEED = 5.0
var SPRINT_SPEED = 10
const JUMP_VELOCITY = 8
const MOUSE_SENSITIVITY = 0.02

#variabili fisica
var gravity = 9.81

@onready var head = $Head
@onready var camera = $Head/Camera3D

#variabili headbob
const Bob_freq = 2.0
const Bob_amp = 0.08
var t_bob = 0.0

#variabili FOV
var Base_fov = 75.0
const fov_change = 1.75

#mouse capturing
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		

func get_wall_run_normal() -> Vector3:
	if Input.is_action_pressed("Jump") and Input.is_action_pressed("Up"):
		if is_on_wall():
			var collision = get_slide_collision(0)
			if collision:
				return collision.get_normal()
	return Vector3.ZERO
				

#movimento e telecamera
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Handle sprint
	if Input.is_action_pressed("Dash"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction : Vector3 = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# CONTROLLO WALL RUN
	var wall_normal = get_wall_run_normal()
	if wall_normal != Vector3.ZERO:
		velocity.y = 0.0 # Cancella la gravità sul muro
		# Calcola la direzione proiettandola lungo la parete
		direction = direction.slide(wall_normal).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7)
	else: 
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3)
		
	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = Base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta*8)

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * Bob_freq) * Bob_amp
	return pos
