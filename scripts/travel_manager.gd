extends Node

enum area_type {SPAWN, SMALL_ROOM, WAREHOUSE}

var area_dict = {
    area_type.SPAWN: 'res://scenes/spawn/spawn.tscn',
    area_type.SMALL_ROOM: 'res://scenes/small_room/small_room.tscn',
    area_type.WAREHOUSE: 'res://scenes/warehouse/warehouse.tscn'
}

var last_area : area_type

func change_area(current_area: area_type):
    last_area = current_area