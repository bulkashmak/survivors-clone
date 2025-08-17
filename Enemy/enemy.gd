extends CharacterBody2D

signal remove_from_array(object)

@export var movement_speed: float = 20.0 # exports the variable to the editor
@export var hp = 10
@export var knockback_recovery = 3.5 # increase this value to reduce knockback

var knockback = Vector2.ZERO

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player") # reference of the first node in group 'player' from the global node tree
@onready var sprite: Sprite2D = $Sprite2D # reference of a node with a given name
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

var death_animation: Resource = preload("res://Enemy/explosion.tscn")

func _ready() -> void:
	animation.play("walk")

func _physics_process(_delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery) # reduce the knockback every frame
	# CharacterBody2D.global_position adds up all position of parent nodes
	# to get the global position in the world
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = movement_speed * direction
	velocity += knockback # add the knockback force to the velocity
	
	# Turning animation
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false
	
	move_and_slide()

func death() -> void:
	emit_signal("remove_from_array", self)
	var enemy_death = death_animation.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	queue_free()

func _on_hurt_box_hurt(damage: Variant, angle, knockback_amount) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		hit_sound.play() # if an enemy didn't die, play a hit sound
