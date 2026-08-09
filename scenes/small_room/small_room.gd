extends Node3D

@onready var bug_patch_node : Node3D = $SubViewportContainer/SubViewport/enemies

func _ready() -> void:
	var children := bug_patch_node.get_children()
	for child in children:
		if child.name in Game.small_room_already_killed:
			child.visible = false
			child.process_mode = Node.PROCESS_MODE_DISABLED


func _on_bug_patch_died(patch_name : Variant) -> void:
	Game.small_room_already_killed.append(patch_name)
	var children := bug_patch_node.get_children()
	for child in children:
		if child.name == patch_name:
			child.process_mode = Node.PROCESS_MODE_DISABLED
	Game.patches_killed += 1
	print(Game.patches_killed)
