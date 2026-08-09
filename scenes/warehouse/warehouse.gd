extends Node3D

@onready var bug_rats : Node3D = $SubViewportContainer/SubViewport/enemies

func _ready() -> void:
	bug_rats.process_mode = Node.PROCESS_MODE_DISABLED
	bug_rats.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	print('body detected')
	if body.is_in_group('player'):
		print('player detected')
		if Game.quests_done == 1:
			Game.light_fuse_turned_on = true
			Game.quest2_light_fuse = false
			Game.quest3_kill_rats = true
			bug_rats.process_mode = Node.PROCESS_MODE_INHERIT
			bug_rats.visible = true
			print('activated quest 3')
			print(Game.quest3_kill_rats)
