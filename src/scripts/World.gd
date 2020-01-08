extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed_fallen = 20

var start_game = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	start_game -= delta
	
	if start_game > 0:
		return;
	
	for c in $Platforms.get_children():
		c.position.y += speed_fallen * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StaticBody2D_body_entered(body):
	if body == $Character:
		print("Game Over")
