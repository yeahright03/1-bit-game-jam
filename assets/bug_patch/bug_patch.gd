extends Node3D

signal swatted
signal died(patch_name)

# enable to view the debug text
@export var debug_text : bool = false

@export var max_health : int = 5
@export var min_health : int = 2
var health : int
@export var invulnerability : bool = false

@export var max_size : float = 1.5
@export var min_size : float = .75
var size : float
var size_decrease_rate : float

@export var disable_sound : bool = false

# time enemy is invincible after being hit
@export var invincibility_time : float = 0.9
@onready var time_since_damage : Timer = $time_since_damage

@onready var scaling_node : Node3D = $scaling_node
@onready var bug_patch_sound : AudioStreamPlayer = $Bug_Patch_Sound
@onready var sound_effect_timer : Timer = $sound_effect_timer

# establishes the values for the bug patch
func _ready() -> void:
	sound_effect_timer.wait_time = randf_range(2.5, 6.5)
	sound_effect_timer.start()
	time_since_damage.wait_time = invincibility_time
	time_since_damage.one_shot = true
	health = randi_range(max_health, min_health)
	size = randf_range(max_size, min_size)
	scaling_node.scale *= size
	size_decrease_rate = size / health
	if debug_text:
		print('%s:\nHealth: %s\nSize: %s\nSize decrease rate: %s' % [self.name, health, size, size_decrease_rate])

# the function is used to damage the bug patch and to decrease its size whenever it takes damage
func swat():
	if time_since_damage.is_stopped() and not invulnerability:
		health -= 1
		time_since_damage.start()
		if debug_text:
			print('Recently damaged: True')
		var decrease_size : Vector3 = Vector3(size_decrease_rate, size_decrease_rate, size_decrease_rate)
		scaling_node.scale -= decrease_size
		swatted.emit()
		if debug_text:
			print('%s took damage! Current health: %s' % [self.name, health])
		if health == 0:
			queue_free()
			died.emit(self.name)
			if debug_text:
				print('%s died!' % self.name)

func _on_sound_effect_timer_timeout() -> void:
	if not disable_sound:
		bug_patch_sound.play()
		sound_effect_timer.wait_time = randf_range(2.5, 6.5)
		sound_effect_timer.start()
