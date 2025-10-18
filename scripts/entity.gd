extends CharacterBody3D

@onready var noise: ColorRect = $noise
@onready var player: CharacterBody3D = $"../../player"
@onready var distort: AudioStreamPlayer3D = $distort

var teleport_timer: Timer
var start_timer: Timer

enum EntityState { HIDDEN, STALK }
var current_state: EntityState = EntityState.HIDDEN

var min_distance: float = 5.0
var max_distance: float = 10.0
var stare_duration: float = 1.0
var stalk_cooldown: float = 5.0

var hidden_position: Vector3 = Vector3(100, 0, 100)
var hidden_cooldown: float = 5.0

var forbidden_radius: float = 20.0

var is_staring: bool = false
var stare_remaining: float = 0.0
var stalk_chance: float = 0.2
var game_started: bool = false

func _ready():
	setup_timers()
	go_hidden()
	start_timer.start(10.0)

func setup_timers():
	teleport_timer = Timer.new()
	teleport_timer.wait_time = hidden_cooldown
	teleport_timer.timeout.connect(_on_teleport_timer_timeout)
	teleport_timer.one_shot = false
	add_child(teleport_timer)
	
	start_timer = Timer.new()
	start_timer.one_shot = true
	start_timer.timeout.connect(_on_start_timer_timeout)
	add_child(start_timer)

func _on_start_timer_timeout():
	game_started = true
	teleport_timer.start()

func _process(delta):
	if not player or not game_started:
		return
	
	if current_state == EntityState.STALK and is_staring:
		var target_pos = player.global_position
		target_pos.y = global_position.y
		look_at(target_pos, Vector3.UP)
		
		stare_remaining -= delta
		if stare_remaining <= 0:
			is_staring = false
			go_hidden()

func _on_teleport_timer_timeout():
	if not game_started:
		return
	
	match current_state:
		EntityState.HIDDEN:
			if randf() < stalk_chance:
				go_stalk()
			else:
				teleport_timer.start()
		
		EntityState.STALK:
			teleport_to_player_nearby()

func go_hidden():
	current_state = EntityState.HIDDEN
	teleport_timer.wait_time = hidden_cooldown
	teleport_timer.start()
	
	global_position = hidden_position
	
	is_staring = false
	if noise:
		noise.hide()
	if distort and distort.playing:
		distort.stop()

func go_stalk():
	current_state = EntityState.STALK
	teleport_timer.wait_time = stalk_cooldown
	teleport_to_player_nearby()
	teleport_timer.start()

func teleport_to_player_nearby():
	if not player:
		return
	
	var player_pos = player.global_position
	var attempts = 0
	var max_attempts = 15
	
	while attempts < max_attempts:
		var angle = randf() * TAU
		var distance = randf_range(min_distance, max_distance)
		
		var new_position = player_pos + Vector3(
			cos(angle) * distance,
			player_pos.y,
			sin(angle) * distance
		)
		
		var distance_from_center = Vector2(new_position.x, new_position.z).distance_to(Vector2.ZERO)
		if distance_from_center >= forbidden_radius:
			global_position = new_position
			
			is_staring = true
			stare_remaining = stare_duration
			
			if distort and not distort.playing:
				distort.play()
			if noise:
				noise.show()
			
			return
		
		attempts += 1
	
	go_hidden()

func _on_close_body_entered(body: Node3D) -> void:
	if body == player and game_started:
		if noise:
			noise.show()
		if distort and not distort.playing:
			distort.play()

func _on_close_body_exited(body: Node3D) -> void:
	if body == player:
		if current_state != EntityState.STALK:
			if noise:
				noise.hide()
			if distort:
				distort.stop()

func trigger_stalk():
	if game_started:
		go_stalk()

func trigger_hide():
	go_hidden()

func get_state_name() -> String:
	match current_state:
		EntityState.HIDDEN: return "HIDDEN"
		EntityState.STALK: return "STALK"
		_: return "UNKNOWN"
