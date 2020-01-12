extends ColorRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var high_score = 0 setget set_high_score
export var score = 0 setget set_score

onready var torch_default_texture = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightLeft.texture

signal restart_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_high_score(hs):
	high_score = hs
	$MarginContainer/VBoxContainer/VBoxContainer2/LblHighScore.text = str(high_score)

func set_score(s):
	score = s
	$MarginContainer/VBoxContainer/VBoxContainer/LblScore.text = str(score)

func show():
	.show()
	$MarginContainer/VBoxContainer/BtnRestart.text = ""
	$MarginContainer/VBoxContainer/BtnRestart.disabled = true
	
	if score > high_score:
		$MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightLeft/AnimationPlayer.play("light")
		$MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightRight/AnimationPlayer2.play("light")
	else:
		$MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightLeft/AnimationPlayer.stop()
		$MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightLeft.texture = torch_default_texture
		$MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightRight/AnimationPlayer2.stop()
		$MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightRight.texture = torch_default_texture
	
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$MarginContainer/VBoxContainer/BtnRestart.disabled = false
	$MarginContainer/VBoxContainer/BtnRestart.text = "Restart"
	
func _on_BtnRestart_pressed():
	emit_signal("restart_game")
