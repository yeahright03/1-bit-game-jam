extends Node3D

@onready var subviewport_container : SubViewportContainer = $SubViewportContainer
var player : CharacterBody3D

func _ready() -> void:
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
			print('activated quest 1')
			print(Game.quest1_patch)
		elif Game.quests_done == 1:
			Game.quest1_patch = false
			Game.quest2_light_fuse = true
			Game.head_light_enabled = true
			print('activated quest 2')
			print(Game.quest2_light_fuse)
		elif Game.quests_done == 3:
			Game.quest3_kill_rats = false
			Game.reset_kills_for_quest4()
			Game.quest4_patch_and_rats = true
			print('activated quest 4')
			print(Game.quest4_patch_and_rats)
