extends Resource

class_name SpawnInfo

@export var time_start: int # when enemies should spawn
@export var time_end: int
@export var enemy: Resource # what enemies should spawn
@export var enemy_num: int # number of enemies that spawn
@export var enemy_spawn_delay: int # seconds delay between spawns

var spawn_delay_counter = 0 # counter for delayed seconds
