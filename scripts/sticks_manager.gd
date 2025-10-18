extends Node3D

const STICK_1 = preload("res://scenes/stick_1.tscn")
const STICK_2 = preload("res://scenes/stick_2.tscn")

@export var total_sticks: int = 100
@export var spawn_radius_min: float = 10.0
@export var spawn_radius_max: float = 100.0

var rng = RandomNumberGenerator.new()

func _ready():
	spawn_sticks()

func spawn_sticks():
	for i in range(total_sticks):
		var stick_scene = STICK_1 if rng.randi() % 2 == 0 else STICK_2
		var new_stick = stick_scene.instantiate()
		add_child(new_stick)
		
		var angle = rng.randf_range(0, TAU)
		var distance = rng.randf_range(spawn_radius_min, spawn_radius_max)
		
		var x = cos(angle) * distance
		var z = sin(angle) * distance
		
		new_stick.position = Vector3(x, 0, z)
		new_stick.rotation_degrees.y = rng.randf_range(0, 360)

func _process(_delta):
	$"../UI/dialogue_manager/sticks".text = "Sticks Collected: " + str(Global.sticks_collected)
