extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const NB_PLATFORMS = 15
const PLATFORM_SPACE = 160

export var speed_fallen = 60

var start_game_delay = 3
var start_game = false
var platform_number = 0
onready var last_platform = $Platforms/Ground

var Platform = preload("res://Platform.tscn")
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	$Character.connect("on_platform_run", self, "on_platform")
	generate_world()

func on_platform(number):
	if number > platform_number:
		platform_number = number
		$Score.text = str(platform_number)

func _process(delta):
	if start_game == false:
		return
	
	start_game_delay -= delta
	
	if start_game_delay > 0:
		return;
	
	for c in $Platforms.get_children():
		c.position.y += speed_fallen * delta
		
		if c.position.y > 2000:
			c.free()
			generate_platform_line()

func generate_platform_line():
	var number = last_platform.number + 1
	var node = Platform.instance()
	node.length_platform = rng.randi_range(2, 5)
	node.number = number
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


func _on_Btn_Start_pressed():
	start_game = true
	$BtnStart.hide()
	$Character.run()
