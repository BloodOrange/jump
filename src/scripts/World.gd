extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const NB_PLATFORMS = 20
const PLATFORM_SPACE = 320
const DEFAULT_SPEED_FALLEN = 60

signal beat_score

var savegame = File.new()
var save_path = "user://savegame.save"
var save_data = {"highscore": 0}

export var speed_fallen = DEFAULT_SPEED_FALLEN

var high_score = 0
var current_score = 0

var start_game_delay = 0
var start_game = false
var last_platform

var Platform = preload("res://Platform.tscn")
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	if not savegame.file_exists(save_path):
		create_file()
	else:
		read_highscore()
	
	$Character.connect("on_platform_run", self, "on_platform")
	reset_world()

func update_highscore():
	$CanvasLayer/StartScreen/HighScore.text = "Best score\n" + str(high_score)

func create_file():
	savegame.open(save_path, File.WRITE)
	savegame.store_var(save_data)
	savegame.close()

func save_highscore():
	save_data["highscore"] = high_score
	savegame.open(save_path, File.WRITE)
	savegame.store_var(save_data)
	savegame.close()

func read_highscore():
	savegame.open(save_path, File.READ) #open the file
	save_data = savegame.get_var() #get the value
	savegame.close() #close the file
	high_score = save_data["highscore"] #return the value
	update_highscore()

func on_platform(platform_node):
	if platform_node.number >= current_score:
		current_score = platform_node.number
		$CanvasLayer/Score.text = str(current_score)
		
		if current_score > high_score:
			emit_signal("beat_score")

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
	
	clear_platforms()
	
	# Reset camera
	$Camera2D.position.y = 0
	
	# Regenerate world
	generate_world()
	
	# Reset parameter
	speed_fallen = DEFAULT_SPEED_FALLEN
	
	# Reset clouds
	for cloud in $ParallaxBckgrd2/Clouds.get_children():
		cloud.reset()

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
	
	if high_score != 0 and number == high_score + 1:
		node.is_highscore = true
		connect("beat_score", node, "turn_on_light")

	if number >= 10000:
		node.set_theme("snow")
	elif number >= 1000:
		node.set_theme("castle")
	elif number >= 300:
		node.set_theme("stone")
	elif number >= 100:
		node.set_theme("sand")
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
		start_game_delay = 0
		
		if current_score > high_score:
			high_score = current_score
			save_highscore()
		
		reset_world()
		$CanvasLayer/StartScreen.show()
	else:
		# Maybe not free to keep the level raising
		# but disable collision for performance
		body.get_parent().free()
		generate_platform_line()


func _on_Btn_Start_pressed():
	current_score = 0
	$CanvasLayer/Score.text = str(current_score)
	start_game = true
	$CanvasLayer/StartScreen.hide()
	$Character.run()

