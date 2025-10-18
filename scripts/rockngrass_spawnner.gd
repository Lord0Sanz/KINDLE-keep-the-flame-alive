extends Node3D

@onready var grass: MeshInstance3D = $grass
@onready var bush: MeshInstance3D = $bush
@onready var stone_small: MeshInstance3D = $stone_small
@onready var stone_big: MeshInstance3D = $stone_big

@export var pregenerate_objects: bool = true
@export var grass_spawn_count: int = 100
@export var bush_spawn_count: int = 50
@export var stone_small_spawn_count: int = 80
@export var stone_big_spawn_count: int = 40
@export var seed_value_grass: int = 11111
@export var seed_value_bush: int = 22222
@export var seed_value_stone_small: int = 33333
@export var seed_value_stone_big: int = 44444
@export var spawn_radius_min: float = 1.5
@export var spawn_radius_max: float = 17.0

@export_group("Wobble Settings")
@export var enable_wobble: bool = true
@export var wobble_strength: float = 0.5
@export var wobble_speed: float = 2.0
@export var wobble_frequency: float = 1.0

var rng = RandomNumberGenerator.new()
var wobble_tweens: Array[Tween] = []

func _ready():
	if Engine.is_editor_hint() and pregenerate_objects:
		pregenerate_in_editor()
	elif not Engine.is_editor_hint():
		spawn_meshes()

func pregenerate_in_editor():
	# Generate grass
	rng.seed = seed_value_grass
	for i in range(grass_spawn_count):
		var new_grass = grass.duplicate()
		add_child(new_grass)
		setup_object_position(new_grass, i)
		if enable_wobble:
			setup_wobble_effect(new_grass, i)
	
	# Generate bush
	rng.seed = seed_value_bush
	for i in range(bush_spawn_count):
		var new_bush = bush.duplicate()
		add_child(new_bush)
		setup_object_position(new_bush, i + grass_spawn_count)
		if enable_wobble:
			setup_wobble_effect(new_bush, i + grass_spawn_count)
	
	# Generate small stones (no wobble)
	rng.seed = seed_value_stone_small
	for i in range(stone_small_spawn_count):
		var new_stone = stone_small.duplicate()
		add_child(new_stone)
		setup_object_position(new_stone, i + grass_spawn_count + bush_spawn_count)
	
	# Generate big stones (no wobble)
	rng.seed = seed_value_stone_big
	for i in range(stone_big_spawn_count):
		var new_stone = stone_big.duplicate()
		add_child(new_stone)
		setup_object_position(new_stone, i + grass_spawn_count + bush_spawn_count + stone_small_spawn_count)
	
	grass.hide()
	bush.hide()
	stone_small.hide()
	stone_big.hide()

func spawn_meshes():
	# Generate grass
	rng.seed = seed_value_grass
	for i in range(grass_spawn_count):
		var new_grass = grass.duplicate()
		add_child(new_grass)
		setup_object_position(new_grass, i)
		if enable_wobble:
			setup_wobble_effect(new_grass, i)
	
	# Generate bush
	rng.seed = seed_value_bush
	for i in range(bush_spawn_count):
		var new_bush = bush.duplicate()
		add_child(new_bush)
		setup_object_position(new_bush, i + grass_spawn_count)
		if enable_wobble:
			setup_wobble_effect(new_bush, i + grass_spawn_count)
	
	# Generate small stones (no wobble)
	rng.seed = seed_value_stone_small
	for i in range(stone_small_spawn_count):
		var new_stone = stone_small.duplicate()
		add_child(new_stone)
		setup_object_position(new_stone, i + grass_spawn_count + bush_spawn_count)
	
	# Generate big stones (no wobble)
	rng.seed = seed_value_stone_big
	for i in range(stone_big_spawn_count):
		var new_stone = stone_big.duplicate()
		add_child(new_stone)
		setup_object_position(new_stone, i + grass_spawn_count + bush_spawn_count + stone_small_spawn_count)
	
	grass.hide()
	bush.hide()
	stone_small.hide()
	stone_big.hide()

func setup_object_position(obj: MeshInstance3D, _index: int):
	var angle = rng.randf_range(0, TAU)
	var distance = rng.randf_range(spawn_radius_min, spawn_radius_max)
	
	var x = cos(angle) * distance
	var z = sin(angle) * distance
	
	obj.position = Vector3(x, 0, z)
	obj.rotation_degrees.y = rng.randf_range(0, 360)
	
	var scale_var = rng.randf_range(0.8, 1.2)
	obj.scale = Vector3(scale_var, scale_var, scale_var)

func setup_wobble_effect(obj: MeshInstance3D, index: int):
	var tween = create_tween()
	tween.set_loops()
	
	var base_rotation = obj.rotation
	var individual_speed = wobble_speed * rng.randf_range(0.8, 1.2)
	var individual_strength = wobble_strength * rng.randf_range(0.7, 1.3)
	
	tween.tween_method(
		func(time):
			var wind_wave = sin(time * individual_speed + index * wobble_frequency) * individual_strength
			var side_wave = cos(time * individual_speed * 0.7 + index * wobble_frequency) * individual_strength * 0.3
			obj.rotation = base_rotation + Vector3(
				wind_wave * 0.01, 
				side_wave * 0.02, 
				wind_wave * 0.005
			),
		0.0,
		1000.0,
		1000.0
	)
	
	wobble_tweens.append(tween)

func _exit_tree():
	for tween in wobble_tweens:
		if tween:
			tween.kill()
