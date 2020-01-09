extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const NB_PLATFORMS = 15
const PLATFORM_SPACE = 160

export var speed_fallen = 20

var start_game = 3
onready var last_platform = $Platforms/Ground

var Platform = preload("res://Platform.tscn")
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate_world()

func _process(delta):
	start_game -= delta
	
	if start_game > 0:
		return;
	
	for c in $Platforms.get_children():
		c.position.y += speed_fallen * delta
		
		if c.position.y > 2000:
			c.free()
			generate_platform_line()

func generate_platform_line():
	var node = Platform.instance()
	node.length_platform = rng.randi_range(1, 5)
	node.position.y = last_platform.position.y - PLATFORM_SPACE
	var length_pixel_plaform = node.BLOCK_SIZE * node.length_platform * node.scale.x
	node.position.x = rng.randf_range(length_pixel_plaform + 10, 1080 - length_pixel_plaform - 10)
	$Platforms.add_child(node)
	last_platform = node

func generate_world():
	for i in range(NB_PLATFORMS):
		generate_platform_line()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StaticBody2D_body_entered(body):
	if body == $Character:
		print("Game Over")
