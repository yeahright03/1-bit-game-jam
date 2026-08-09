extends Node3D

@onready var subviewport_container : SubViewportContainer = $SubViewportContainer
var player : CharacterBody3D
@onready var bug_patch_node : Node3D = $SubViewportContainer/SubViewport/enemies
var patches : Array

func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')
	if Game.quest1_patch or Game.quests_done == 0:
		$Task_Light.visible = false
	patches = bug_patch_node.get_children()
	for patch in patches:
		if patch.name in Game.quest1_patch_already_killed:
			patch.visible = false
			patch.process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if player.health > 3:
		subviewport_container.material.set_shader_parameter('u_contrast', 5.5)
	if player.health > 1 and player.health <= 3:
		subviewport_container.material.set_shader_parameter('u_contrast', 10.0)
	if player.health <= 1:
		subviewport_container.material.set_shader_parameter('u_contrast', 40.0)


func _on_bug_patch_died(patch_name : Variant) -> void:
	if Game.quest1_patch:
		Game.quest1_patch_already_killed.append(patch_name)
		Game.patches_killed += 1
		print(Game.patches_killed)


func _on_proto_controller_player_died() -> void:
	Game.reset_everything()
	get_tree().change_scene_to_file('res://scenes/spawn/spawn.tscn')
