extends Area3D

@export var current_area_type : TravelManager.area_type
@export var change_area_type : TravelManager.area_type

func _ready() -> void:
	add_to_group('change_area')

	if TravelManager.last_area == change_area_type:
		_set_player_position()

func _set_player_position() -> void:
	await get_tree().process_frame

	var player = get_tree().get_first_node_in_group('player')

	var target_position = player.global_position - global_position.direction_to($Marker3D.global_position)
	target_position.y = player.global_position.y

	player.look_at(target_position)
	player.global_position = $Marker3D.global_position
	player.capture_mouse()
	#var mouse_position := InputEventMouseMotion.position
	player.rotate_look(Vector2($Marker3D.global_position.x, $Marker3D.global_position.z))

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		TravelManager.change_area(current_area_type)
		
		get_tree().change_scene_to_file.call_deferred(TravelManager.area_dict[change_area_type])
