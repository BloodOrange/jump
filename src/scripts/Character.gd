extends KinematicBody2D

signal on_platform_run

const GRAVITY = 1500.0
const WALK_SPEED = 400
var velocity = Vector2(WALK_SPEED, 0)
var falling = true
var jump = false
var grip = false
var run = false

func run():
	run = true

func _physics_process(delta):
	if run == false:
		return
	
	if is_on_floor():
		grip = false
		velocity.y = 100
		falling = false
		if is_on_wall():
			velocity.x *= -1
	else:
		if is_on_wall():
			if velocity.x > 0:
				grip = 'right'
			else:
				grip = 'left'
			falling = false
			if velocity.y < 0:
				velocity.y = 0
			velocity.y += delta * GRAVITY * 0.3
		else:
			grip = false
			velocity.y += delta * GRAVITY
			falling = true
			
	# Jump
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and (is_on_floor() or is_on_wall()) and jump == false:
		velocity.y -= 800
		jump = true
		if is_on_wall():
			if grip == 'left':
				velocity.x = WALK_SPEED
			elif grip == 'right':
				velocity.x = -WALK_SPEED

	if !Input.is_mouse_button_pressed(BUTTON_LEFT):
		jump = false

    # We don't need to multiply velocity by delta because "move_and_slide" already takes delta time into account.

    # The second parameter of "move_and_slide" is the normal pointing up.
    # In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	move_and_slide(velocity, Vector2(0, -1))
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var node = collision.collider.get_parent()
		if not node.get("number") == null:
			emit_signal("on_platform_run", node.number)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Animation
	$AnimatedSprite.rotation_degrees = 0
	if falling:
		$AnimatedSprite.animation = "jump"
		if velocity.x > 0:
			$AnimatedSprite.flip_h = false
		elif velocity.x < 0:
			$AnimatedSprite.flip_h = true
	elif grip:
		$AnimatedSprite.animation = "grip"
		if grip == 'right':
			$AnimatedSprite.rotation_degrees = -90
			$AnimatedSprite.flip_v = false
		elif grip == 'left':
			$AnimatedSprite.rotation_degrees = 90
			$AnimatedSprite.flip_h = true
	else:
		if velocity.x != 0:
			$AnimatedSprite.animation = "walk"
			$AnimatedSprite.play()
			if velocity.x > 0:
				$AnimatedSprite.flip_h = false
			if velocity.x < 0:
				$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.animation = "stay"

