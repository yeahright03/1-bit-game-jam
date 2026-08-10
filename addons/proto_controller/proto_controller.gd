# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

signal player_died

@export_group("Movement Modifiers")
## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we hold to crouch?
@export var can_crouch : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 5.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we crouch?
@export var crouch_speed : float = 2.5
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to Crouch.
@export var input_crouch : String = "crouch"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"
## Name of Input Action to toggle Attack
@export var input_attack : String = "attack"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var currently_crouching : bool = false

@export_group("Health Modifiers")
@export var health : float = 5.0
@export var health_regen : float = 0.1
@export var healing_interval : float = 1.0
@export var invincibility_time : float = 0.5

## IMPORTANT REFERENCES
@onready var head : Node3D = $Head
@onready var collider : CollisionShape3D = $Collider
@onready var hitbox : Area3D = $Head/Camera3D/WeaponPivot/Flyswatter2/Hitbox
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var camera : Camera3D = $Head/Camera3D
@onready var time_since_damage : Timer = $time_since_damage
@onready var healing_interval_timer : Timer = $healing_interval
@onready var head_light : SpotLight3D = $Head/head_light
@onready var hit_sound_effect : AudioStreamPlayer = $hit_sound_effect


func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("attack"):
		if hit_sound_effect.playing == false:
			hit_sound_effect.play()
		anim_player.play("attack")
		hitbox.monitoring = true 

func _ready() -> void:
	add_to_group('player')
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	healing_interval_timer.wait_time = healing_interval
	time_since_damage.wait_time = invincibility_time
	time_since_damage.one_shot = true
	anim_player.play("idle")
	hitbox.monitoring = false

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting or crouching
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	elif can_crouch and Input.is_action_pressed(input_crouch):
		move_speed = crouch_speed
		currently_crouching = true
	else:
		move_speed = base_speed
		currently_crouching = false
	
	# Modify camera height and collider size based on if currently crouching
	if can_crouch and currently_crouching and Input.is_action_just_pressed(input_crouch):
		head.position.y -= 1
		collider.shape.height -= .5
	elif can_crouch and not currently_crouching and Input.is_action_just_released(input_crouch):
		head.position.y += 1
		collider.shape.height += .5


	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0

	if Game.head_light_enabled:
		head_light.visible = true
	else:
		head_light.visible = false

	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)

		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("enemy") and time_since_damage.is_stopped():
			time_since_damage.start()
			taking_damage(1)
	
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_crouch and not InputMap.has_action(input_crouch):
		push_error("Crouching disabled. No InputAction found for input_crouch: " + input_crouch)
		can_crouch = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false

## Is the weapon in idle?
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		anim_player.play("idle")
		hitbox.monitoring = false

## Is the enemy hit?
func _on_hitbox_body_entered(body: Node3D) -> void:
	await get_tree().create_timer(.5).timeout
	if body != CharacterBody3D: 
		var hitbox : StaticBody3D = $body/StaticBody3D
		if body != null:
			if body.is_in_group('enemy'):
				var enemy = body.get_parent().get_parent()
				enemy.swat()
				print("enemy hit")

func taking_damage(damage_taken: float = 1.0) -> void:
	var random_offset : float = randf_range(0.1, 0.3)
	camera.rotation.z += random_offset
	await get_tree().create_timer(0.05).timeout
	camera.rotation.z -= 2 * random_offset
	await get_tree().create_timer(0.05).timeout
	camera.rotation.z += random_offset
	health -= damage_taken
	if health < 0:
		player_died.emit()


func _on_healing_interval_timeout() -> void:
	print(health)
	if health < 5:
		health += health_regen
