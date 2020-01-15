extends KinematicBody2D

signal on_platform_run

const DEFAULT_GRAVITY = 3500.0
const WALK_SPEED = 400
const LEFT = 1
const RIGHT = -1
const DEFAULT_JUMPING_DELAY = 0.3

var velocity = Vector2(WALK_SPEED, 0)
var is_running = false
var direction = LEFT
var jumping_delay = 0
var finished_jump = false

var gravity = DEFAULT_GRAVITY

onready var character_start_position = position

var Alien_Blue_Animation = preload("res://assets/Player/CharacterBlueAnimation.tres")
var Alien_Green_Animation = preload("res://assets/Player/CharacterGreenAnimation.tres")
var Alien_Pink_Animation = preload("res://assets/Player/CharacterPinkAnimation.tres")
var Alien_Yellow_Animation = preload("res://assets/Player/CharacterYellowAnimation.tres")
var Zombie_Animation = preload("res://assets/Player/CharacterZombieAnimation.tres")

enum Action {
	walking,
	falling,
	jumping,
	gripping,
	waiting
}

var action = Action.waiting

func _ready():
	PlayerInfo.connect("current_player_changed", self, "_on_current_player_changed")
	_on_current_player_changed()

func run():
	is_running = true

func stop():
	is_running = false

func reset():
	stop()
	action = Action.waiting
	direction = LEFT
	velocity = Vector2(WALK_SPEED, 0)
	$AnimatedSprite.rotation_degrees = 0
	$AnimatedSprite.animation = "stay"
	$DustParticle.emitting = false
	$AnimatedSprite.play()
	position = character_start_position

var release_key = true
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and can_jump():
			to_jump()
		elif !event.is_pressed():# and jumping_delay > 0:
			finished_jump = true
	
	# For test
	if event is InputEventKey and event.scancode == KEY_SPACE:
		if event.is_pressed() and can_jump() and release_key:
			to_jump()
			release_key = false
		elif !event.is_pressed():
			finished_jump = true
			release_key = true

func die():
	if PlayerInfo.vibrate_enabled:
		Input.vibrate_handheld(200)

func can_jump():
	return action == Action.walking or action == Action.gripping or action == Action.jumping

func update_animation():
	if action == Action.gripping:
		$AnimatedSprite.rotation_degrees = -90 * direction
	else:
		$AnimatedSprite.rotation_degrees = 0
	
	$AnimatedSprite.flip_h = direction == RIGHT
	
	if action == Action.jumping or action == Action.falling:
		$AnimatedSprite.animation = "jump"
	elif action == Action.gripping:
		$AnimatedSprite.animation = "grip"
	elif action == Action.walking:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.animation = "stay"

func to_fall():
	if action == Action.falling:
		return
	
	action = Action.falling
	
	$DustParticle.emitting = false
	update_animation()

func to_jump():
	if action == Action.jumping:
		return

	finished_jump = false
	velocity.y -= 2000
	jumping_delay = DEFAULT_JUMPING_DELAY
	action = Action.jumping
	
	PlayerInfo.jump_count += 1
	
	$DustParticle.emitting = false
	if PlayerInfo.vibrate_enabled:
		Input.vibrate_handheld(50)
	
	if is_on_wall():
		direction *= -1 # Change direction
		velocity.x = direction * WALK_SPEED
	update_animation()

func to_walk():
	if action == Action.walking:
		return
	
	action = Action.walking
	velocity.y = 100 # Little force to keep player on ground
	
	$DustParticle.emitting = true
	update_animation()

func to_grip():
	if action == Action.gripping:
		return
	
	if velocity.y < 0: # Don't slide on wall
		velocity.y = 0
	
	action = Action.gripping
	update_animation()

func update_state():
	if is_on_floor():
		jumping_delay = 0
		gravity = DEFAULT_GRAVITY
		to_walk()
		if is_on_wall(): # Change direction
			velocity.x *= -1
			direction *= -1
			update_animation()
	else:
		if is_on_wall():
			jumping_delay = 0
			gravity = DEFAULT_GRAVITY
			to_grip()
		elif action != Action.jumping:
			to_fall()

func apply_gravity(delta):
	if action == Action.falling or action == Action.jumping:
		velocity.y += delta * gravity
	elif action == Action.gripping:
		velocity.y += delta * gravity * 0.3

func set_text(text):
	var label1 = get_node("/root/World/GuiLayer/VBoxContainer/Label")
	var label2 = get_node("/root/World/GuiLayer/VBoxContainer/Label2")
	
	if text == label2.text:
		return
	
	label1.text = label2.text
	label2.text = text

func _physics_process(delta):
	if is_running == false:
		return
	
	if finished_jump and action == Action.jumping and velocity.y > -1150 and velocity.y < -100:
		velocity.y = -100
		to_fall()
	
	move_and_slide(velocity, Vector2(0, -1))
	
	var old_action = action
	
	update_state()
	
	apply_gravity(delta)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.collision_layer == 2:
			var node = collision.collider.get_parent()
			emit_signal("on_platform_run", node)
			set_text("ground_" + str(node.number))
		elif collision.collider.collision_layer == 4:
			set_text("wall")
		else:
			set_text("other")

func _on_current_player_changed():
	var alien_animation = Alien_Green_Animation
	
	if PlayerInfo.current_player == PlayerInfo.ALIEN_BLUE:
		alien_animation = Alien_Blue_Animation
	elif PlayerInfo.current_player == PlayerInfo.ALIEN_PINK:
		alien_animation = Alien_Pink_Animation
	elif PlayerInfo.current_player == PlayerInfo.ALIEN_GREEN:
		alien_animation = Alien_Green_Animation
	elif PlayerInfo.current_player == PlayerInfo.ALIEN_YELLOW:
		alien_animation = Alien_Yellow_Animation
	elif PlayerInfo.current_player == PlayerInfo.ZOMBIE:
		alien_animation = Zombie_Animation
	
	$AnimatedSprite.frames = alien_animation
