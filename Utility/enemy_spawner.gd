extends Node2D

@export var spawns: Array[SpawnInfo] = []

var time = 0

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _on_timer_timeout() -> void:
	time += 1
	var enemy_spawns = spawns
	for spawn in enemy_spawns:
		if time >= spawn.time_start and time <= spawn.time_end: # is it a time peried when enemies should spawn
			if spawn.spawn_delay_counter < spawn.enemy_spawn_delay: # check if there is a delay
				spawn.spawn_delay_counter += 1 # increase coutner by 1 for next time
			else:
				spawn.spawn_delay_counter = 0 # reset delay counter
				var new_enemy: Resource = spawn.enemy
				var counter = 0
				while counter < spawn.enemy_num:
					var enemy_spawn = new_enemy.instantiate() # create instance of packed scene
					enemy_spawn.global_position = get_random_position() # set a random global position
					add_child(enemy_spawn) # actually spawn the enemy
					counter += 1 # increase counter until all enemies are spawned

func get_random_position() -> Vector2:
	# To get a random position we take the size of our viewport and multiply it
	var vpr: Vector2 = get_viewport_rect().size * randf_range(1.1, 1.4)
	# Set corners
	var top_left = Vector2(
			player.global_position.x - vpr.x/2,
			player.global_position.y - vpr.y/2
	)
	var top_right = Vector2(
			player.global_position.x + vpr.x/2,
			player.global_position.y - vpr.y/2
	)
	var bottom_left = Vector2(
			player.global_position.x - vpr.x/2,
			player.global_position.y + vpr.y/2
	)
	var bottom_right = Vector2(
			player.global_position.x + vpr.x/2,
			player.global_position.y + vpr.y/2
	)
	var pos_side = ["up", "down", "right", "left"].pick_random() # pick random value in array
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	# Pick a side
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	# Get a value between the points
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	
	return Vector2(x_spawn, y_spawn)
