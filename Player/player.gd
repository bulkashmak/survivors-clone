extends CharacterBody2D

var movement_speed: float = 40.0 # pixels
var hp = 80

# Attacks
var ice_spear = preload("res://Player/Attack/ice_spear.tscn")

# AttackNodes
@onready var ice_spear_timer: Timer = get_node("%IceSpearTimer")
@onready var ice_spear_attack_timer: Timer = get_node("%IceSpearAttackTimer")

# IceSpear
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

# Enemy Related
var enemy_close = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var walk_timer: Timer = get_node("%WalkTimer")

func _ready() -> void:
	attack()

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

func attack() -> void:
	if icespear_level > 0:
		ice_spear_timer.wait_time = icespear_attackspeed # set reload timer to attack speed
		if ice_spear_timer.is_stopped(): # start the reload timer if it's stopped
			ice_spear_timer.start()

func _on_hurt_box_hurt(damage: Variant, _angle, _knockback) -> void:
	hp -= damage
	print(hp)

func _on_ice_spear_timer_timeout() -> void:
	icespear_ammo += icespear_baseammo # load the ammo
	ice_spear_attack_timer.start() # start the attack

func _on_ice_spear_attack_timer_timeout() -> void:
	if icespear_ammo > 0:
		var icespear_attack: Node = ice_spear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			ice_spear_attack_timer.start()
		else:
			ice_spear_attack_timer.stop()

func get_random_target() -> Vector2:
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)
