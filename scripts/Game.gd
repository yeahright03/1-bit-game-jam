extends Node

var health_transfer : float = 0
var rotation_transfer : Vector3 = Vector3(0, 0, 0)

var quest1_patch : bool = false
var quest2_light_fuse : bool = false
var quest3_kill_rats : bool = false
var quest4_patch_and_rats : bool = false
var quest5_escape : bool = false
var head_light_enabled : bool = false

var patches_killed : int = 0
var light_fuse_turned_on : bool = false
var bug_rats_killed : int = 0

var quest1_patch_already_killed : Array
var quest3_kill_rats_already_killed : Array
var quest4_patch_and_rats_already_killed : Array

var quests_done : int = 0

func reset_everything() -> void:
    health_transfer = 0
    rotation_transfer = Vector3(0, 0, 0)

    quest1_patch = false
    quest2_light_fuse = false
    quest3_kill_rats = false
    quest4_patch_and_rats = false
    quest5_escape = false

    patches_killed = 0
    light_fuse_turned_on = false
    bug_rats_killed = 0

    quest1_patch_already_killed = []

    quests_done = 0

func reset_kills_for_quest4() -> void:
    patches_killed = 0
    bug_rats_killed = 0