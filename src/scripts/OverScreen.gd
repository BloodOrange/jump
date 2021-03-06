extends ColorRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var high_score = 0 setget set_high_score
export var score = 0 setget set_score

var torch_off_texture = preload("res://assets/World1/Items/torch.png")
var torch_animated_texture = preload("res://assets/light_animation_gameover.tres")

onready var restart_node = $MarginContainer/VBoxContainer/CenterContainer/BtnRestart
onready var score_node = $MarginContainer/VBoxContainer/VBoxContainer/LblScore
onready var high_score_node = $MarginContainer/VBoxContainer/VBoxContainer2/LblHighScore
onready var light_left_node = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightLeft
onready var light_right_node = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureLightRight

signal restart_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_high_score(hs):
	high_score = hs
	high_score_node.text = str(high_score)

func set_score(s):
	score = s
	score_node.text = str(score)

func show():
	.show()
	restart_node.hide()
	
	if score > high_score:
		light_left_node.texture = torch_animated_texture
		light_right_node.texture = torch_animated_texture
	else:
		light_left_node.texture = torch_off_texture
		light_right_node.texture = torch_off_texture
	
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	restart_node.show()
	
func _on_BtnRestart_pressed():
	emit_signal("restart_game")
