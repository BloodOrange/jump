extends Control

var Alien_Blue_Badge = preload("res://assets/Player/AlienBlue/alienBlue_badge1.png")
var Alien_Green_Badge = preload("res://assets/Player/AlienGreen/alienGreen_badge1.png")
var Alien_Pink_Badge = preload("res://assets/Player/AlienPink/alienPink_badge1.png")
var Alien_Yellow_Badge = preload("res://assets/Player/AlienYellow/alienYellow_badge1.png")
var Zombie_Badge = preload("res://assets/Player/Zombie/Poses/head_focus.png")

var Vibrate_Icon = preload("res://assets/Icons/vibrating-smartphone.png")
var No_Vibrate_Icon = preload("res://assets/Icons/novibrating-smartphone.png")
var Settings_Icon = preload("res://assets/Icons/cog.png")
var Settings_Close_Icon = preload("res://assets/Icons/sideswipe.png")

var settings_open = false
onready var btn_vibrate = $Panel/MarginContainer/HBoxContainer/BtnVibrate
onready var btn_sound = $Panel/MarginContainer/HBoxContainer/BtnSound

signal start_game()

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInfo.connect("vibrate_enabled_changed", self, "_on_vibrate_enabled_changed")
	PlayerInfo.connect("current_player_changed", self, "_on_current_player_changed")

func _on_vibrate_enabled_changed():
	if PlayerInfo.vibrate_enabled:
		$Panel/MarginContainer/HBoxContainer/BtnVibrate.icon = Vibrate_Icon
	else:
		$Panel/MarginContainer/HBoxContainer/BtnVibrate.icon = No_Vibrate_Icon

func _on_current_player_changed():
	var alien_badge = Alien_Green_Badge
	
	if PlayerInfo.current_player == PlayerInfo.ALIEN_BLUE:
		alien_badge = Alien_Blue_Badge
	elif PlayerInfo.current_player == PlayerInfo.ALIEN_PINK:
		alien_badge = Alien_Pink_Badge
	elif PlayerInfo.current_player == PlayerInfo.ALIEN_GREEN:
		alien_badge = Alien_Green_Badge
	elif PlayerInfo.current_player == PlayerInfo.ALIEN_YELLOW:
		alien_badge = Alien_Yellow_Badge
	elif PlayerInfo.current_player == PlayerInfo.ZOMBIE:
		alien_badge = Zombie_Badge
	
	$BtnCharacterSelection.icon = alien_badge

func _on_Btn_Character_selection_pressed():
	$PopupPanel.popup()

func _on_ItemList_Character_selected(index):
	var alien = PlayerInfo.ZOMBIE
	
	if index == 0:
		alien = PlayerInfo.ALIEN_PINK
	elif index == 1:
		alien = PlayerInfo.ALIEN_BLUE
	elif index == 3:
		alien = PlayerInfo.ALIEN_YELLOW
	elif index == 4:
		alien = PlayerInfo.ZOMBIE
	else:
		alien = PlayerInfo.ALIEN_GREEN
	
	PlayerInfo.current_player = alien
	PlayerInfo.save_info()
	
	#$Character/AnimatedSprite.frames = animation
	$PopupPanel.hide()


func _on_BtnStart_pressed():
	if settings_open:
		close_settings()
	emit_signal("start_game")

func _on_BtnVibrate_pressed():
	PlayerInfo.vibrate_enabled = !PlayerInfo.vibrate_enabled
	PlayerInfo.save_info()

func open_settings():
	$Panel/OpenPanelAnimation.play("drawer_shown")
	$BtnOpenClose.icon = Settings_Close_Icon
	settings_open = true

func close_settings():
	$Panel/OpenPanelAnimation.play_backwards("drawer_shown")
	$BtnOpenClose.icon = Settings_Icon
	settings_open = false

func _on_BtnOpenClose_pressed():
	if settings_open:
		close_settings()
	else:
		open_settings()

func _on_BtnRAZ_pressed():
	PlayerInfo.high_score = 0
