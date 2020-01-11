extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const LIGHT_ANIMATION = preload("res://assets/light_animation.tres")

const GRASS_ONCE = preload("res://assets/Tiles/grassHalf.png")
const GRASS_LEFT = preload("res://assets/Tiles/grassHalfLeft.png")
const GRASS_MID  = preload("res://assets/Tiles/grassHalfMid.png")
const GRASS_RIGHT = preload("res://assets/Tiles/grassHalfRight.png")

const SAND_ONCE = preload("res://assets/Tiles/sandHalf.png")
const SAND_LEFT = preload("res://assets/Tiles/sandHalfLeft.png")
const SAND_MID  = preload("res://assets/Tiles/sandHalfMid.png")
const SAND_RIGHT = preload("res://assets/Tiles/sandHalfRight.png")

const CASTLE_ONCE = preload("res://assets/Tiles/castleHalf.png")
const CASTLE_LEFT = preload("res://assets/Tiles/castleHalfLeft.png")
const CASTLE_MID  = preload("res://assets/Tiles/castleHalfMid.png")
const CASTLE_RIGHT = preload("res://assets/Tiles/castleHalfRight.png")

const DIRT_ONCE = preload("res://assets/Tiles/dirtHalf.png")
const DIRT_LEFT = preload("res://assets/Tiles/dirtHalfLeft.png")
const DIRT_MID  = preload("res://assets/Tiles/dirtHalfMid.png")
const DIRT_RIGHT = preload("res://assets/Tiles/dirtHalfRight.png")

const SNOW_ONCE = preload("res://assets/Tiles/snowHalf.png")
const SNOW_LEFT = preload("res://assets/Tiles/snowHalfLeft.png")
const SNOW_MID  = preload("res://assets/Tiles/snowHalfMid.png")
const SNOW_RIGHT = preload("res://assets/Tiles/snowHalfRight.png")

const STONE_ONCE = preload("res://assets/Tiles/stoneHalf.png")
const STONE_LEFT = preload("res://assets/Tiles/stoneHalfLeft.png")
const STONE_MID  = preload("res://assets/Tiles/stoneHalfMid.png")
const STONE_RIGHT = preload("res://assets/Tiles/stoneHalfRight.png")

const BLOCK_SIZE = 70

export var length_platform = 0 setget length_platform_set, length_platform_get
export var number = 0

var theme_once = GRASS_ONCE
var theme_left = GRASS_LEFT
var theme_mid = GRASS_MID
var theme_right = GRASS_RIGHT

var is_highscore = false
var lights = []

# Called when the node enters the scene tree for the first time.
func _ready():
	length_platform_set(length_platform)

func set_theme(theme):
	if theme == "sand":
		theme_once  = SAND_ONCE
		theme_left  = SAND_LEFT
		theme_mid   = SAND_MID
		theme_right = SAND_RIGHT
	elif theme == "castle":
		theme_once  = CASTLE_ONCE
		theme_left  = CASTLE_LEFT
		theme_mid   = CASTLE_MID
		theme_right = CASTLE_RIGHT
	elif theme == "snow":
		theme_once  = SNOW_ONCE
		theme_left  = SNOW_LEFT
		theme_mid   = SNOW_MID
		theme_right = SNOW_RIGHT
	elif theme == "stone":
		theme_once  = STONE_ONCE
		theme_left  = STONE_LEFT
		theme_mid   = STONE_MID
		theme_right = STONE_RIGHT
	else:
		theme_once  = GRASS_ONCE
		theme_left  = GRASS_LEFT
		theme_mid   = GRASS_MID
		theme_right = GRASS_RIGHT

func length_platform_set(new_length):
	length_platform = new_length
	
	$StaticBody2D/CollisionShape2D.scale.x = new_length
	
	for n in $Picture.get_children():
		$Picture.remove_child(n)
	
	if length_platform == 1:
		var new_block = Sprite.new()
		new_block.texture = theme_once
		$Picture.add_child(new_block)
		if is_highscore:
			add_light(new_block.position)
	else:
		var posx = -((length_platform - 1) * BLOCK_SIZE) / 2
		
		for i in range(length_platform):
			var new_block = Sprite.new()
			new_block.position.x = posx
			posx += BLOCK_SIZE
			$Picture.add_child(new_block)
			
			if i == 0:
				new_block.texture = theme_left
				if is_highscore:
					add_light(new_block.position)
			elif i == length_platform - 1:
				new_block.texture = theme_right
				if is_highscore:
					add_light(new_block.position)
			else:
				new_block.texture = theme_mid

func length_platform_get():
	return length_platform

func add_light(pos):
	var light = AnimatedSprite.new()
	light.name = "light"
	light.frames = LIGHT_ANIMATION
	light.animation = "off"
	light.position = pos
	light.position.y -= 70
	$Picture.add_child(light)
	lights.append(light)

func turn_on_light():
	for l in lights:
		l.animation = "on"
		l.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
