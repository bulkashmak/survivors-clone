extends CharacterBody2D

signal remove_from_array(object)

@export var movement_speed: float = 20.0 # exports the variable to the editor
@export var hp = 10
@export var knockback_recovery = 3.5

var knockback = Vector2.ZERO

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player") # reference of the first node in group 'player' from the global node tree
@onready var sprite: Sprite2D = $Sprite2D # reference of a node with a given name
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation.play("walk")

func _physics_process(_delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	# CharacterBody2D.global_position adds up all position of parent nodes
	# to get the global position in the world
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = movement_speed * direction
	velocity += knockback
	
	# Turning animation
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false
	
	move_and_slide()


func _on_hurt_box_hurt(damage: Variant, angle, knockback_amount) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()
