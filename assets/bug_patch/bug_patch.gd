extends Node3D

signal swatted
signal died

# enable to view the debug text
@export var debug_text : bool = false

@export var max_health : int = 5
@export var min_health : int = 2
var health : int

@export var max_size : float = 1.5
@export var min_size : float = .75
var size : float
var size_decrease_rate : float

@onready var scaling_node : Node3D = $scaling_node


# establishes the values for the bug patch
func _ready() -> void:
	health = randi_range(max_health, min_health)
	size = randf_range(max_size, min_size)
	self.scale *= size
	size_decrease_rate = size / health
	if debug_text:
		print('%s\nHealth: %s\nSize: %s\nSize decrease rate: %s' % [self.name, health, size, size_decrease_rate])

# only for debug usage to test damage systems
func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ENTER):
		self.swat()

# the function is used to damage the bug patch and to decrease its size whenever it takes damage
func swat():
	health -= 1
	var decrease_size : Vector3 = Vector3(size_decrease_rate, size_decrease_rate, size_decrease_rate)
	scaling_node.scale -= decrease_size
	swatted.emit()
	if debug_text:
		print('%s took damage! Current health: %s' % [self.name, health])
	if health == 0:
		queue_free()
		died.emit()
		if debug_text:
			print('%s died!' % self.name)
