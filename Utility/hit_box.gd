extends Area2D

@export var damage = 1

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var disable_timer: Timer = $DisableHitBoxTimer

func tempdisable() -> void:
	collision.set_deferred("disabled", true)
	disable_timer.start()


func _on_disable_hit_box_timer_timeout() -> void:
	collision.set_deferred("disabled", false)
