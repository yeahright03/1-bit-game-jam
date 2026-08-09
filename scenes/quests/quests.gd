extends Control

@onready var quest_text : Label = $quest_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Game.quest1_patch:
		if Game.patches_killed < 3:
			quest_text.text = 'Current task:\nRemove bug nests: %s/3' % Game.patches_killed
		elif Game.patches_killed == 3:
			quest_text.text = 'Current task:\nGet back to boss'
			Game.quests_done = 1
	elif Game.quest2_light_fuse:
		quest_text.text = 'Current task:\nTurn on the light breaker'
		if Game.light_fuse_turned_on:
			Game.quests_done = 2
	elif Game.quest3_kill_rats:
		quest_text.text = 'Current task:\nKill rat things: %s/3' % Game.bug_rats_killed
		if Game.bug_rats_killed == 3:
			Game.quests_done = 3
			quest_text.text = 'Current task:\nGet back to boss'
	elif Game.quest4_patch_and_rats:
		quest_text.text = 'Current task:\nRemove bug nests: %s/3\nKill rat things: %s/3' % [Game.patches_killed, Game.bug_rats_killed]
		if Game.patches_killed == 3 and Game.bug_rats_killed == 3:
			Game.quests_done = 4
			quest_text.text = 'Current task:\nGet back to boss'
	else:
		quest_text.text = 'Nothing to do at the moment.'

