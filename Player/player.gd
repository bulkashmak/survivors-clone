extends CharacterBody2D

var movement_speed: float = 40.0 # pixels

@onready var sprite: Sprite2D = $Sprite2D
@onready var walk_timer: Timer = get_node("%WalkTimer")

func _physics_process(delta: float) -> void: # runs every 1/60 seconds
	movement()
	
func movement() -> void:
	# The way this works is:
	# If D key is pressed, then x_mov = 1 - 0 which is 1
	# If A key is pressed, then x_mov = 0 - 1 which is -1
	# This indicates in which direction on x/y axis the player is supposed to move
	var x_mov: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	# The same applies to y_mov as for x_mov
	var y_mov: float = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov: Vector2 = Vector2(x_mov, y_mov)
	
	# Turning animation
	# If player is moving right, then flip the sprite
	# If player is moving left, then don't flip the sprite
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
	
	# Walking animation
	# Vector2.ZERO is {0, 0}, in this case means that player is not moving
	if mov != Vector2.ZERO:
		if walk_timer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walk_timer.start()
	
	velocity = movement_speed * mov.normalized()
	# Why is there a Vector2.normalized()
	# This has to do with Pythagorean theorem
	# For example, if mov = Vector2(1, 1), then the player should move diagonally
	# So, the player will be moved N (which is movement speed) pixels right and N pixels down
	# This will actually be faster than N, because a^2 * b^2 = c^2
	# In our case a = 1 and b = 1, so c is equal to square root of 1 + 1 which is ~1.4
	# This means that our player will be moving approx. 40% faster diagonally, than horizontally and vertically
	# To avoid this, we should use Vector2.normalized()
	
	move_and_slide()
