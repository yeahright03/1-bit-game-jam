extends Node

var quest1_patch : bool = false
var quest2_light_fuse : bool = false
var quest3_kill_rats : bool = false
var quest4_patch_and_rats : bool = false

var patches_killed : int = 0
var light_fuse_turned_on : bool = false
var bug_rats_killed : int = 0
var patches_and_rats_killed : int = 0

var small_room_already_killed : Array

var quests_done : int = 0

func reset_kills():
    patches_killed = 0
    bug_rats_killed = 0
    patches_and_rats_killed = 0