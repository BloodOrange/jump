extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const GRASS_ONCE = preload("res://assets/Tiles/grassHalf.png")
const GRASS_LEFT = preload("res://assets/Tiles/grassHalfLeft.png")
const GRASS_MID  = preload("res://assets/Tiles/grassHalfMid.png")
const GRASS_RIGHT = preload("res://assets/Tiles/grassHalfRight.png")

const BLOCK_SIZE = 70

export var length_platform = 2 setget length_platform_set, length_platform_get

# Called when the node enters the scene tree for the first time.
func _ready():
	length_platform_set(length_platform)

func length_platform_set(new_length):
	length_platform = new_length
	
	$StaticBody2D/CollisionShape2D.scale.x = new_length
	
	for n in $Picture.get_children():
		$Picture.remove_child(n)
	
	if length_platform == 1:
		var new_block = Sprite.new()
		new_block.texture = GRASS_ONCE
		$Picture.add_child(new_block)
	else:
		var posx = -((length_platform - 1) * BLOCK_SIZE) / 2
		
		for i in range(length_platform):
			var new_block = Sprite.new()
			new_block.position.x = posx
			posx += BLOCK_SIZE
			$Picture.add_child(new_block)
			
			if i == 0:
				new_block.texture = GRASS_LEFT
			elif i == length_platform - 1:
				new_block.texture = GRASS_RIGHT
			else:
				new_block.texture = GRASS_MID

func length_platform_get():
	return length_platform

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
