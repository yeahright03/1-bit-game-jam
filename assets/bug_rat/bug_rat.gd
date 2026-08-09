extends CharacterBody3D

signal swatted
signal died(bug_rat_name)

enum agression_state {ROAMING, RETREAT, AGRESSIVE}
var state : agression_state = agression_state.ROAMING

# enable to view the debug text
@export var debug_text : bool = false

@export var max_health : int = 3
@export var min_health : int = 2
var health : int

@export var max_size : float = 2
@export var min_size : float = 1
var size : float
var size_decrease_rate : float

@export var vision_range : float = 10.0

var target_pos : Vector3
var has_target : bool = false
var nav_server : RID = get_rid()
@export var speed : float = 6.0
@export var agressive_speed_modifier : float = 2.0
@export var retreat_speed_modifier : float = 1.5
@export var nav_map : NavigationRegion3D
var nav_mesh : NavigationMesh
var random_locations : PackedVector3Array
var location_array_range : int
var player_position : Vector3
@export var retreat_range : float = 25.0

# time enemy is invincible after being hit
@export var invincibility_time : float = 0.9
@onready var time_since_damage : Timer = $time_since_damage

@export var disable_movement : bool = false

@onready var scaling_node : Node3D = $scaling_node
@onready var bug_color : StandardMaterial3D = $scaling_node/bug.get_surface_override_material(0)
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var vision_cone : CollisionShape3D = $vision_mechanics/vision_area/vision_cone
@onready var vision_line : RayCast3D = $vision_mechanics/vision_line
@onready var vision_area : Area3D = $vision_mechanics/vision_area
@onready var vision_timer : Timer = $vision_mechanics/vision_timer
@onready var marker : Marker3D = $Marker3D


# establishes the values for the bug patch
func _ready() -> void:
	time_since_damage.wait_time = invincibility_time
	time_since_damage.one_shot = true
	vision_cone.scale *= vision_range
	nav_mesh  = nav_map.navigation_mesh
	random_locations = nav_mesh.get_vertices()
	location_array_range = random_locations.size()
	state = agression_state.ROAMING
	health = randi_range(max_health, min_health)
	size = randf_range(max_size, min_size)
	scaling_node.scale *= size
	if debug_text:
		print('%s:\nHealth: %s\nSize: %s' % [self.name, health, size])

# REMOVE ON RELEASE
# only for debug usage to test damage systems
func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ENTER):
		self.swat()
	if Input.is_key_pressed(KEY_N):
		has_target = true
		target_pos = Vector3(random_locations.get(randi_range(0, location_array_range - 1)))


# the function is used to damage and flash the bug upon getting hit
func swat():
	if time_since_damage.is_stopped():
		health -= 1
		time_since_damage.start()
		bug_color.emission = Color(1, 1, 1, 1)
		await get_tree().create_timer(.1).timeout
		bug_color.emission = Color(0, 0, 0, 1)
		swatted.emit()
		if debug_text:
			print('%s took damage! Current health: %s' % [self.name, health])
		if health == 0:
			queue_free()
			died.emit(self.name)
			if debug_text:
				print('%s died!' % self.name)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and not disable_movement:
		velocity += get_gravity() * delta

	if has_target and not disable_movement:
		nav_agent.target_position = target_pos
		var next_path_pos := nav_agent.get_next_path_position()
		var direction := global_position.direction_to(next_path_pos)
		if state == agression_state.ROAMING:
			velocity = direction * speed
		elif state == agression_state.RETREAT:
			velocity = direction * speed * retreat_speed_modifier
		elif state == agression_state.AGRESSIVE:
			velocity = direction * speed * agressive_speed_modifier

		if nav_agent.is_navigation_finished() and state == agression_state.AGRESSIVE:
			vision_timer.stop()
			state = agression_state.RETREAT
			has_target = true
			while true:
				target_pos = Vector3(random_locations.get(randi_range(0, location_array_range - 1)))
				if target_pos.distance_to(self.position) < retreat_range:
					break
		elif nav_agent.is_navigation_finished():
			if state == agression_state.RETREAT:
				vision_timer.start()
				state = agression_state.ROAMING
			has_target = false
			velocity = Vector3.ZERO

		var rotation_speed = 4
		var target_rotation := direction.signed_angle_to(Vector3.MODEL_REAR, Vector3.DOWN)
		if abs(target_rotation - rotation.y) > deg_to_rad(60):
			rotation_speed = 20
		rotation.y = move_toward(rotation.y, target_rotation, delta * rotation_speed)

	move_and_slide()


func _on_vision_timer_timeout() -> void:
	var overlaps = vision_area.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == 'ProtoController':
				player_position = overlap.global_transform.origin
				var vector_to_player : Vector3 = Vector3(player_position - self.position).normalized()
				var front_vector : Vector3 = Vector3(marker.global_position - self.position).normalized()
				var angle : float = front_vector.dot(vector_to_player)
				#print(angle)
				vision_line.look_at(player_position, Vector3.UP)
				vision_line.force_raycast_update()

				if vision_line.is_colliding() and angle > 0:
					var collider = vision_line.get_collider()

					if collider.name == 'ProtoController':
						print('%s sees the player!' % self.name)
						state = agression_state.AGRESSIVE
						has_target = true
						target_pos = player_position
					else:
						print('%s DO NOT see the player!' % self.name)
			if overlap.name == null:
				continue


func _on_roam_timer_timeout() -> void:
	if state == agression_state.ROAMING:
		has_target = true
		target_pos = Vector3(random_locations.get(randi_range(0, location_array_range - 1)))
