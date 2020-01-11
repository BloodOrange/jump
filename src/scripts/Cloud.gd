extends Sprite

export var speed = 7
export var going_right = true
onready var init_position = position
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if going_right == true:
		position.x += speed*delta
	else:
		position.x -= speed*delta
		
func reset():
	position = init_position