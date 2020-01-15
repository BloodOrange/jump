extends Node

const ALIEN_PINK = "AlienPink"
const ALIEN_GREEN = "AlienGreen"
const ALIEN_BLUE  = "AlienBlue"
const ALIEN_YELLOW = "AlienYellow"
const ZOMBIE = "Zombie"

var current_player = "AlienPink" setget set_current_player
signal current_player_changed()

func set_current_player(new_current_player):
	current_player = new_current_player
	emit_signal("current_player_changed")

# Score
var high_score = 0 setget set_high_score
signal high_score_changed()

func set_high_score(new_high_score):
	high_score = new_high_score
	emit_signal("high_score_changed")

var current_score = 0 setget set_current_score
signal current_score_changed()

func set_current_score(new_current_score):
	current_score = new_current_score
	emit_signal("current_score_changed")

# Statistics
var platform_touch = 0 setget set_platform_touch
signal platform_touch_changed()

func set_platform_touch(new_platform_touch):
	platform_touch = new_platform_touch
	emit_signal("platform_touch_changed")

var jump_count = 0 setget set_jump_count
signal jump_count_changed()

func set_jump_count(new_jump_count):
	jump_count = new_jump_count
	emit_signal("jump_count_changed")

# Settings
var vibrate_enabled = true setget set_vibrate_enabled
signal vibrate_enabled_changed()

func set_vibrate_enabled(new_vibrate_enabled):
	vibrate_enabled = new_vibrate_enabled
	emit_signal("vibrate_enabled_changed")

var sound_enabled = true setget set_sound_enabled
signal sound_enabled_changed()

func set_sound_enabled(new_sound_enabled):
	sound_enabled = new_sound_enabled
	emit_signal("sound_enabled_changed")

# Leveling
# var level
# var xp

# Blocking content
# var player1_block = true


# Save
var savegame = File.new()
var save_data = {}
const SAVE_PATH = "user://savegame.save"

func save_info():
	save_data["highscore"] = high_score
	save_data["current_player"] = current_player
	save_data["platform_touch"] = platform_touch
	save_data["jump_count"] = jump_count
	save_data["vibrate_enabled"] = vibrate_enabled
	save_data["sound_enabled"] = sound_enabled

	savegame.open(SAVE_PATH, File.WRITE)
	savegame.store_var(save_data)
	savegame.close()

func load_info():
	if not savegame.file_exists(SAVE_PATH):
		save_info()
	else:
		savegame.open(SAVE_PATH, File.READ)
		save_data = savegame.get_var()
		savegame.close()
		
		if save_data.has("highscore"):
			set_high_score(save_data["highscore"])
		if save_data.has("current_player"):
			set_current_player(save_data["current_player"])
		if save_data.has("platform_touch"):
			set_platform_touch(save_data["platform_touch"])
		if save_data.has("jump_count"):
			set_jump_count(save_data["jump_count"])
		if save_data.has("vibrate_enabled"):
			set_vibrate_enabled(save_data["vibrate_enabled"])
		if save_data.has("sound_enabled"):
			set_sound_enabled(save_data["sound_enabled"])
