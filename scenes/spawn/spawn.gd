extends Node3D

@onready var subviewport_container : SubViewportContainer = $SubViewportContainer
@onready var end_enemies : Node3D = $SubViewportContainer/SubViewport/end_enemies
@onready var boss_door_hide : MeshInstance3D = $SubViewportContainer/SubViewport/NavigationRegion3D/SpawnRoom/BossDoor_hide
@onready var exit_door_hide : MeshInstance3D = $SubViewportContainer/SubViewport/NavigationRegion3D/SpawnRoom/Exitdoor_hide
var player : CharacterBody3D

func _ready() -> void:
	if Game.quests_done == 4:
		boss_door_hide.visible = false
	if not Game.quest5_escape:
		end_enemies.process_mode = Node.PROCESS_MODE_DISABLED
		end_enemies.visible = false
	player = get_tree().get_first_node_in_group('player')
	if not Game.quest1_patch:
		$Task_Light.visible = false

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
		if Game.quests_done == 0:
			Game.quest1_patch = true
			$Task_Light.visible = true
			DialogueManager.show_example_dialogue_balloon(load("res://dialouge/quest1.dialogue"), "start")
			return
			print('activated quest 1')
			print(Game.quest1_patch)
		elif Game.quests_done == 1:
			Game.quest1_patch = false
			Game.quest2_light_fuse = true
			Game.head_light_enabled = true
			DialogueManager.show_example_dialogue_balloon(load("res://dialouge/quest2.dialogue"), "start")
			return
			print('activated quest 2')
			print(Game.quest2_light_fuse)
		elif Game.quests_done == 3:
			Game.quest3_kill_rats = false
			Game.reset_kills_for_quest4()
			Game.quest4_patch_and_rats = true
			DialogueManager.show_example_dialogue_balloon(load("res://dialouge/quest4.dialogue"), "start")
			return
			print('activated quest 4')
			print(Game.quest4_patch_and_rats)
		elif Game.quests_done == 4:
			Game.quest4_patch_and_rats = false
			Game.quest5_escape = true
			exit_door_hide.visible = false
			exit_door_hide.process_mode = Node.PROCESS_MODE_DISABLED
			end_enemies.visible = true
			end_enemies.process_mode = Node.PROCESS_MODE_INHERIT
			DialogueManager.show_example_dialogue_balloon(load("res://dialouge/quest5.dialogue"), "start")
			return
			print('activated quest 5')


func _on_proto_controller_player_died() -> void:
	Game.reset_everything()
	get_tree().change_scene_to_file('res://scenes/spawn/spawn.tscn')


func _on_area_3d_3_body_entered(body: Node3D) -> void:
	print('body detected')
	if body.is_in_group('player'):
		print('player detected')
		Game.reset_everything()
		get_tree().change_scene_to_file('res://scenes/spawn/spawn.tscn')
