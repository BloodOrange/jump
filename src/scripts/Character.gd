extends KinematicBody2D

const GRAVITY = 1500.0
const WALK_SPEED = 200
var velocity = Vector2()
var falling = true

func _physics_process(delta):

	if is_on_floor():
		velocity.y = 100
		falling = false
	else:
		velocity.y += delta * GRAVITY
		falling = true
	print(falling)

	# Move right / left
	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0

	# Jump
	if Input.is_action_pressed('ui_up') and is_on_floor():
		velocity.y -= 800
	

    # We don't need to multiply velocity by delta because "move_and_slide" already takes delta time into account.

    # The second parameter of "move_and_slide" is the normal pointing up.
    # In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	move_and_slide(velocity, Vector2(0, -1))

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Animation
	if falling:
		$AnimatedSprite.animation = "jump"
		if velocity.x > 0:
			$AnimatedSprite.flip_h = false
		elif velocity.x < 0:
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

