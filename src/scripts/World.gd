extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const NB_PLATFORMS = 20
const PLATFORM_SPACE = 320
const DEFAULT_SPEED_FALLEN = 60

export var speed_fallen = DEFAULT_SPEED_FALLEN

var start_game_delay = 3
var start_game = false
var platform_number = 0
var last_platform

var Platform = preload("res://Platform.tscn")
var rng = RandomNumberGenerator.new()

var character_start_position

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	$Character.connect("on_platform_run", self, "on_platform")
	character_start_position = $Character.position
	reset_world()

func on_platform(number):
	if number > platform_number:
		platform_number = number
		$CanvasLayer/Score.text = str(platform_number)

func clear_platforms():
	for p in $Platforms.get_children():
		p.free()
	
	# Make ground platform
	var ground = Platform.instance()
	ground.length_platform = 10
	ground.position = Vector2(540, 1500)
	$Platforms.call_deferred("add_child", ground)
	last_platform = ground

func reset_world():
	$Character.reset()
	$Character.position = character_start_position
	
	clear_platforms()
	
	# Reset camera
	$Camera2D.position.y = 0
	
	# Regenerate world
	generate_world()
	
	# Reset parameter
	speed_fallen = DEFAULT_SPEED_FALLEN

func _process(delta):
	if start_game == false:
		return
	
	start_game_delay -= delta
	
	if start_game_delay > 0:
		return;
		
	$Camera2D.position.y -= speed_fallen * delta
	var distance = $Character.position.y - $Camera2D.position.y
	#print($Character.position.y, " - ", $Camera2D.position.y, " = ", distance)
	if distance < 400:
		$Camera2D.position.y = $Character.position.y - 400

func generate_platform_line():
	var number = last_platform.number + 1
	var node = Platform.instance()
	node.length_platform = rng.randi_range(2, 5)
	node.number = number
	node.position.y = last_platform.position.y - PLATFORM_SPACE
	var length_pixel_plaform = node.BLOCK_SIZE * node.length_platform * node.scale.x
	node.position.x = rng.randf_range(length_pixel_plaform + 10, 1080 - length_pixel_plaform - 10)
	$Platforms.call_deferred("add_child", node)
	last_platform = node

func generate_world():
	for i in range(NB_PLATFORMS):
		generate_platform_line()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StaticBody2D_body_entered(body):
	if body == $Character:
		start_game = false
		start_game_delay = 3
		reset_world()
		$CanvasLayer/BtnStart.show()
	else:
		# Maybe not free to keep the level raising
		# but disable collision for performance
		body.get_parent().free()
		generate_platform_line()


func _on_Btn_Start_pressed():
	platform_number = 0
	$CanvasLayer/Score.text = str(platform_number)
	start_game = true
	$CanvasLayer/BtnStart.hide()
	$Character.run()

