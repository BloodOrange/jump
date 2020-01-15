extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const NB_PLATFORMS = 20
const PLATFORM_SPACE = 320
const DEFAULT_SPEED_FALLEN = 60

signal beat_score

export var speed_fallen = DEFAULT_SPEED_FALLEN

var start_game_delay = 0
var start_game = false
var last_platform_generated
var last_platform

var Platform = preload("res://Platform.tscn")
var rng = RandomNumberGenerator.new()

onready var charactersList = $GuiLayer/StartScreen/PopupPanel/CenterContainer/ItemList

const is_server = true

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("Current player: " + PlayerInfo.current_player)
		print("High score: " + str(PlayerInfo.high_score))
		print("Platforms touched: " + str(PlayerInfo.platform_touch))
		print("Jump count: " + str(PlayerInfo.jump_count))
		print("Vibrate enable: " + str(PlayerInfo.vibrate_enabled))
		print("Sound enable: " + str(PlayerInfo.sound_enabled))

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	PlayerInfo.connect("high_score_changed", self, "_on_high_score_changed")
	
	PlayerInfo.load_info()
	
#	if is_server:
#		var peer = NetworkedMultiplayerENet.new()
#		peer.create_server("6060", 4)
#		get_tree().setNetwork_peer(peer)
#	else:
#		var peer = NetworkedMultiplayerENet.new()
#		peer.create_client("192.168.1.16", "6060")
#		get_tree().set_network_peer(peer)
	
	$Character.connect("on_platform_run", self, "on_platform")
	$GuiLayer/StartScreen.connect("start_game", self, "_on_start_game")
	
	reset_world()

func _on_high_score_changed():
	update_highscore()

func update_highscore():
	$GuiLayer/StartScreen/HighScore.text = "Best score\n" + str(PlayerInfo.high_score)

func on_platform(platform_node):
	if last_platform.number != platform_node.number:
		PlayerInfo.platform_touch += 1
	
	last_platform = platform_node
	
	if platform_node.number >= PlayerInfo.current_score:
		PlayerInfo.current_score = platform_node.number
		$GuiLayer/Score.text = str(PlayerInfo.current_score)
		
		if PlayerInfo.current_score > PlayerInfo.high_score:
			emit_signal("beat_score")

func clear_platforms():
	for p in $Platforms.get_children():
		p.free()
	
	# Make ground platform
	var ground = Platform.instance()
	ground.length_platform = 10
	ground.position = Vector2(540, 1500)
	$Platforms.call_deferred("add_child", ground)
	last_platform_generated = ground
	last_platform = ground

func stop_world():
	$Character.stop()
	start_game = false

func reset_world():
	$GuiLayer/Score.hide()
	
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
	
	# Reset Stars
	$StarsLayer/Stars.hide()
	$StarsLayer/Stars.emitting = false

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
	var number = last_platform_generated.number + 1
	var node = Platform.instance()
	
	if PlayerInfo.high_score != 0 and number == PlayerInfo.high_score + 1:
		node.is_highscore = true
		connect("beat_score", node, "turn_on_light")

	if number >= 1000:
		node.set_theme("castle")
	elif number >= 500:
		node.set_theme("stone")
	elif number >= 250:
		node.set_theme("snow")
	elif number >= 100:
		node.set_theme("sand")
	node.length_platform = rng.randi_range(2, 5)
	node.number = number
	node.position.y = last_platform_generated.position.y - PLATFORM_SPACE
	var length_pixel_plaform = node.BLOCK_SIZE * node.length_platform * node.scale.x
	node.position.x = rng.randf_range(length_pixel_plaform + 10, 1080 - length_pixel_plaform - 10)
	$Platforms.call_deferred("add_child", node)
	last_platform_generated = node
	
	if number == 150:
		$StarsLayer/Stars.emitting = true
		$StarsLayer/Stars.show()

func generate_world():
# warning-ignore:unused_variable
	for i in range(NB_PLATFORMS):
		generate_platform_line()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_StaticBody2D_body_entered(body):
	if body == $Character:
		start_game = false
		start_game_delay = 0
		
		$Character.die()
		
		stop_world()
		$GuiLayer/OverScreen.score = PlayerInfo.current_score
		$GuiLayer/OverScreen.high_score = PlayerInfo.high_score
		
		if PlayerInfo.current_score > PlayerInfo.high_score:
			PlayerInfo.high_score = PlayerInfo.current_score
			update_highscore()

		PlayerInfo.save_info()
		$GuiLayer/OverScreen.show()
	else:
		# Maybe not free to keep the level raising
		# but disable collision for performance
		body.get_parent().free()
		generate_platform_line()

func _on_start_game():
	PlayerInfo.current_score = 0
	$GuiLayer/Score.text = str(PlayerInfo.current_score)
	start_game = true
	$GuiLayer/StartScreen.hide()
	$GuiLayer/Score.show()
	$Character.run()

func _on_Restart_game():
	$GuiLayer/OverScreen.hide()
	$GuiLayer/StartScreen.show()
	
	reset_world()
