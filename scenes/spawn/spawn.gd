extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print('body detected')
	if body.is_in_group('player'):
		print('player detected')
		if Game.quests_done == 0:
			Game.quest1_patch = true
			print('activated quest 1')
			print(Game.quest1_patch)
		elif Game.quests_done == 1:
			Game.quest1_patch = false
			Game.quest2_light_fuse = true
			print('activated quest 2')
			print(Game.quest1_patch)