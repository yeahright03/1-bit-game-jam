extends Node3D

signal swatted
signal died

# enable to view the debug text
@export var debug_text : bool = false

@export var max_health : int = 5
@export var min_health : int = 2
var health : int

@export var max_size : float = 2
@export var min_size : float = 1
var size : float
var size_decrease_rate : float

@onready var scaling_node : Node3D = $scaling_node
@onready var bug_color : StandardMaterial3D = $scaling_node/bug.get_surface_override_material(0)


# establishes the values for the bug patch
func _ready() -> void:
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

# the function is used to damage and flash the bug upon getting hit
func swat():
	await get_tree().create_timer(.5).timeout
	health -= 1
	bug_color.emission = Color(1, 1, 1, 1)
	await get_tree().create_timer(.1).timeout
	bug_color.emission = Color(0, 0, 0, 1)
	swatted.emit()
	if debug_text:
		print('%s took damage! Current health: %s' % [self.name, health])
	if health == 0:
		queue_free()
		died.emit()
		if debug_text:
			print('%s died!' % self.name)
