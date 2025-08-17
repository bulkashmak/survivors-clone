extends Area2D

signal hurt(damage, angle, knockback)

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

var hit_once_array = [] # used to hold attacks that have already hit

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
					if hit_once_array.has(area) == false: # check if attack isn't in array
						hit_once_array.append(area) # add to the array, to ignore the future attack hits
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array", Callable(self, "remove_from_list")):
								area.connect("remove_from_array", Callable(self, "remove_from_list"))
					else:
						return # if attack is in array, return and skip the hurt signal
				2: # DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			if not area.get("angle") == null: # check if attack actually has an angle var
				angle = area.angle # set the angle to our attack
			if not area.get("knockback_amount") == null: # check if attack has a knockback_amount var
				knockback = area.knockback_amount # set knockback to our attack
			
			emit_signal("hurt", damage, angle, knockback) # add attack args to the hurt signal
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout() -> void:
	collision.set_deferred("disabled", false)
