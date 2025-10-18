extends Node3D

@onready var tree_1: MeshInstance3D = $tree_1
@onready var tree_2: MeshInstance3D = $tree_2
@onready var tree_3: MeshInstance3D = $tree_3

@export var pregenerate_trees: bool = true
@export var spawn_count_per_type: int = 100
@export var seed_value_tree_1: int = 12345
@export var seed_value_tree_2: int = 67890
@export var seed_value_tree_3: int = 54321
@export var spawn_radius_min: float = 1.5
@export var spawn_radius_max: float = 17.0

@export_group("Natural Distribution")
@export var min_distance_between_trees: float = 1.5
@export var fill_density: float = 0.85
@export var cluster_intensity: float = 0.6

@export_group("Wobble Settings")
@export var enable_wobble: bool = true
@export var wobble_strength: float = 0.5
@export var wobble_speed: float = 2.0
@export var wobble_frequency: float = 1.0

var rng = RandomNumberGenerator.new()
var wobble_tweens: Array[Tween] = []

func _ready():
	if Engine.is_editor_hint() and pregenerate_trees:
		pregenerate_in_editor()
	elif not Engine.is_editor_hint():
		spawn_meshes()

func pregenerate_in_editor():
	generate_tree_type(tree_1, spawn_count_per_type, seed_value_tree_1, 0)
	generate_tree_type(tree_2, spawn_count_per_type, seed_value_tree_2, spawn_count_per_type)
	generate_tree_type(tree_3, spawn_count_per_type, seed_value_tree_3, spawn_count_per_type * 2)
	tree_1.hide()
	tree_2.hide()
	tree_3.hide()

func spawn_meshes():
	generate_tree_type(tree_1, spawn_count_per_type, seed_value_tree_1, 0)
	generate_tree_type(tree_2, spawn_count_per_type, seed_value_tree_2, spawn_count_per_type)
	generate_tree_type(tree_3, spawn_count_per_type, seed_value_tree_3, spawn_count_per_type * 2)
	tree_1.hide()
	tree_2.hide()
	tree_3.hide()

func generate_tree_type(tree_template: MeshInstance3D, count: int, seed_val: int, index_offset: int):
	rng.seed = seed_val
	var placed_positions: Array[Vector3] = []
	var cluster_centers: Array[Vector3] = []
	var cluster_count = int(count * 0.15)
	
	for i in cluster_count:
		var angle = rng.randf_range(0, TAU)
		var distance = rng.randf_range(spawn_radius_min, spawn_radius_max * 0.9)
		var x_pos = cos(angle) * distance
		var z_pos = sin(angle) * distance
		cluster_centers.append(Vector3(x_pos, 0, z_pos))
	
	var trees_placed = 0
	var attempts = 0
	
	while trees_placed < count and attempts < count * 5:
		var tree_position: Vector3
		
		if cluster_centers.size() > 0 and rng.randf() < cluster_intensity:
			var cluster_center = cluster_centers[randi() % cluster_centers.size()]
			var cluster_radius = rng.randf_range(2.0, 6.0)
			var cluster_angle = rng.randf_range(0, TAU)
			var cluster_distance = rng.randf_range(0, cluster_radius)
			tree_position = cluster_center + Vector3(
				cos(cluster_angle) * cluster_distance,
				0,
				sin(cluster_angle) * cluster_distance
			)
		else:
			var angle = rng.randf_range(0, TAU)
			var distance = rng.randf_range(spawn_radius_min, spawn_radius_max)
			tree_position = Vector3(
				cos(angle) * distance,
				0,
				sin(angle) * distance
			)
		
		if is_position_valid(tree_position, placed_positions) and rng.randf() < fill_density:
			var new_tree = tree_template.duplicate()
			add_child(new_tree)
			setup_tree_position(new_tree, tree_position, trees_placed + index_offset)
			if enable_wobble:
				setup_wobble_effect(new_tree, trees_placed + index_offset)
			placed_positions.append(tree_position)
			trees_placed += 1
		attempts += 1

func is_position_valid(tree_position: Vector3, placed_positions: Array[Vector3]) -> bool:
	for existing_pos in placed_positions:
		if tree_position.distance_to(existing_pos) < min_distance_between_trees:
			return false
	var distance_from_center = Vector2(tree_position.x, tree_position.z).length()
	if distance_from_center < spawn_radius_min or distance_from_center > spawn_radius_max:
		return false
	return true

func setup_tree_position(tree: MeshInstance3D, tree_position: Vector3, _index: int):
	tree.position = tree_position
	tree.rotation_degrees.y = rng.randf_range(0, 360)
	var scale_var = rng.randf_range(0.7, 1.3)
	tree.scale = Vector3(scale_var, scale_var, scale_var)

func setup_wobble_effect(tree: MeshInstance3D, index: int):
	var tween = create_tween()
	tween.set_loops()
	var base_rotation = tree.rotation
	var individual_speed = wobble_speed * rng.randf_range(0.8, 1.2)
	var individual_strength = wobble_strength * rng.randf_range(0.7, 1.3)
	tween.tween_method(
		func(time):
			var wind_wave = sin(time * individual_speed + index * wobble_frequency) * individual_strength
			var side_wave = cos(time * individual_speed * 0.7 + index * wobble_frequency) * individual_strength * 0.3
			tree.rotation = base_rotation + Vector3(
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
