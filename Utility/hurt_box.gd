extends Area2D

signal hurt(damage)

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var disable_timer: Timer = $DisableTimer

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: # Cooldown
					collision.set_deferred("disabled", true)
					disable_timer.start()
				1: # HitOnce
					pass
				2: # DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			
			var damage = area.damage
			emit_signal("hurt", damage)

func _on_disable_timer_timeout() -> void:
	collision.set_deferred("disabled", false)
