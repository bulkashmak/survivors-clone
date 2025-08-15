extends Area2D

var level = 1
var hp = 1
var speed = 100
var damage = 5
var knock_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	angle = global_position.direction_to(target)
	# Set rotation in radians
	# .angle() turns a Vector2 to a radian
	# We add radians which are converted from 135 deg, because the spear in it's initial state is rotated -45 deg
	# This makes the spear face right which is Vector(1, 0)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			hp = 1
			speed = 100
			damage = 5
			knock_amount = 100
			attack_size = 1.0
	
	# Tweens is a way to alternate node's properties in an animated like fashion
	# First we create a tween
	var tween = create_tween()
	# Then we set it up by providing the node itself, the property of a node, the end result of that property and the time it will take to alternate the property
	# There can be multiple properties. By default they will play one by one. To play them in parallel we should set tween.parallel to true
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 1)\
			.set_trans(Tween.TRANS_QUINT)\
			.set_ease(Tween.EASE_OUT)
	# Finally we play the tween
	tween.play()

func _physics_process(delta: float) -> void:
	# eg. Vector2(0.7, 0.7) * 100 * 0.0167
	position += angle * speed * delta

func enemy_hit(charge = 1) -> void: # get's called every time icespear hits an enemy
	hp -= charge
	if hp <= 0:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free() # delete ice spear after a timer times out
