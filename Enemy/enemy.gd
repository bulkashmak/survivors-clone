extends CharacterBody2D

@export var movement_speed: float = 20.0 # exports the variable to the editor

# Gets the first node in group 'player' from the global node tree
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation.play("walk")

func _physics_process(_delta: float) -> void:
	# CharacterBody2D.global_position adds up all position of parent nodes
	# to get the global position in the world
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = movement_speed * direction
	
	# Turning animation
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false
	
	move_and_slide()
