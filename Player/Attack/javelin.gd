extends Area2D

signal remove_from_array(object)

var level = 1
var hp = 9999
var speed = 200.0
var damage = 19
var knockback_amount = 100
var paths = 1
var attack_size = 1.0
var attack_speed = 4.0

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var spr_jav_reg = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_atk = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = get_node("%AttackTimer")
@onready var change_direction_timer: Timer = get_node("ChangeDirectionTimer")
@onready var reset_pos_timer: Timer = get_node("ResetPositionTimer")
@onready var snd_attack: AudioStreamPlayer2D = $AttackSound

func _ready() -> void:
	update_javelin()
	_on_reset_position_timer_timeout()

func update_javelin() -> void:
	level = player.javelin_level
	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			attack_size = 1.0
			attack_speed = 4.0
	
	scale = Vector2(1.0, 1.0) * attack_size
	attack_timer.wait_time = attack_speed

func _physics_process(delta: float) -> void:
	if target_array.size() == 0:
		position += angle * speed * delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_dif = global_position - player.global_position # get distance between javelin and player
		var return_speed = 20
		if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500: # if distance is over 500 then increase return speed
			return_speed = 100
		position += player_angle * return_speed * delta # return speed used to speed up
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)

func add_paths() -> void:
	snd_attack.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()

func process_path() -> void:
	angle = global_position.direction_to(target)
	change_direction_timer.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rotation_degrees, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enable_attack(atk = true) -> void:
	if atk:
		collision.call_deferred("set", "disabled", false)
		sprite.texture = spr_jav_atk
	else:
		collision.call_deferred("set", "disabled", true)
		sprite.texture = spr_jav_reg

func _on_attack_timer_timeout() -> void:
	add_paths()

func _on_change_direction_timer_timeout() -> void:
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			snd_attack.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		change_direction_timer.stop()
		attack_timer.start()
		enable_attack(false)

func _on_reset_position_timer_timeout() -> void:
	var choose_direction = randi() % 4 # choose a number from 0 to 3
	reset_pos = player.global_position # set reset position to players global position
	match choose_direction: # change reset pos by 50 pixels
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
