extends Node

var game_controller : GameController

func _ready() -> void:
    GlobalController.game_controller = self
