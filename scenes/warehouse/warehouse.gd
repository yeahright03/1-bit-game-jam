extends Node3D

@onready var subviewport_container : SubViewportContainer = $SubViewportContainer
var player : CharacterBody3D
@onready var bug_rats : Node3D = $SubViewportContainer/SubViewport/rats
@onready var rats_and_patches : Node3D = $SubViewportContainer/SubViewport/rats_and_patches
@onready var lights : Node3D = $Lights
var rats : Array
var rats_and_patches_collection : Array

func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')
	rats = bug_rats.get_children()
	rats_and_patches_collection = rats_and_patches.get_children()
	if not Game.light_fuse_turned_on:
		lights.visible = false
		bug_rats.process_mode = Node.PROCESS_MODE_DISABLED
		bug_rats.visible = false
		rats_and_patches.process_mode = Node.PROCESS_MODE_DISABLED
		rats_and_patches.visible = false
	elif Game.quest3_kill_rats:
		for rat in rats:
			if rat.name in Game.quest3_kill_rats_already_killed:
				rat.visible = false
				rat.process_mode = Node.PROCESS_MODE_DISABLED
		rats_and_patches.process_mode = Node.PROCESS_MODE_DISABLED
		rats_and_patches.visible = false
	elif Game.quest4_patch_and_rats:
		for rat_and_patch in rats_and_patches_collection:
			if rat_and_patch.name in Game.quest4_patch_and_rats_already_killed:
				rat_and_patch.visible = false
				rat_and_patch.process_mode = Node.PROCESS_MODE_DISABLED
		bug_rats.process_mode = Node.PROCESS_MODE_DISABLED
		bug_rats.visible = false

func _process(_delta: float) -> void:
	if player.health > 3:
		subviewport_container.material.set_shader_parameter('u_contrast', 5.5)
	if player.health > 1 and player.health <= 3:
		subviewport_container.material.set_shader_parameter('u_contrast', 10.0)
	if player.health <= 1:
		subviewport_container.material.set_shader_parameter('u_contrast', 40.0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	print('body detected')
	if body.is_in_group('player'):
		print('player detected')
		if Game.quests_done == 1:
			lights.visible = true
			Game.light_fuse_turned_on = true
			Game.quest2_light_fuse = false
			Game.quest3_kill_rats = true
			bug_rats.process_mode = Node.PROCESS_MODE_INHERIT
			bug_rats.visible = true
			print('activated quest 3')
			print(Game.quest3_kill_rats)


func _on_bug_rat_died(bug_rat_name) -> void:
	if Game.quest3_kill_rats:
		Game.quest3_kill_rats_already_killed.append(bug_rat_name)
		Game.bug_rats_killed += 1
		print(Game.bug_rats_killed)
	elif Game.quest4_patch_and_rats:
		Game.quest4_patch_and_rats_already_killed.append(bug_rat_name)
		Game.bug_rats_killed += 1
		print(Game.bug_rats_killed)


func _on_bug_patch_died(patch_name: Variant) -> void:
	if Game.quest4_patch_and_rats:
		Game.quest4_patch_and_rats_already_killed.append(patch_name)
		Game.patches_killed += 1
		print(Game.patches_killed)


func _on_proto_controller_player_died() -> void:
	Game.reset_everything()
	get_tree().change_scene_to_file('res://scenes/spawn/spawn.tscn')
