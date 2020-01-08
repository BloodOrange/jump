extends KinematicBody2D

const GRAVITY = 1500.0
const WALK_SPEED = 400
var velocity = Vector2(WALK_SPEED, 0)
var falling = true
var jump = false

func _physics_process(delta):
	
	if is_on_wall():
		velocity.x *= -1
		
	if is_on_floor():
		velocity.y = 100
		falling = false
	else:
		velocity.y += delta * GRAVITY
		falling = true

	# Jump
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and (is_on_floor() or is_on_wall()):
		velocity.y -= 800
		jump = false
	

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

