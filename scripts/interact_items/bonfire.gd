extends Interactables

signal doll_1_burned
signal doll_2_burned
signal doll_3_burned
signal doll_4_burned

@onready var doll_burned: AudioStreamPlayer3D = $doll_burned
@onready var fire_health: ProgressBar = $fire_health/SubViewport/fire_health
@onready var camp_fire: OmniLight3D = $camp_fire
@onready var flames: GPUParticles3D = $camp_fire/flames
@onready var doll: MeshInstance3D = $bon_fire/doll
@onready var campfire_audio: AudioStreamPlayer3D = $camp_fire/campfire
@onready var add_items_audio: AudioStreamPlayer3D = $camp_fire/add_items
@onready var doll_burn_audio: AudioStreamPlayer3D = $camp_fire/add_items
@onready var fire_health_sprite: Sprite3D = $fire_health
@onready var fade_anim: AnimationPlayer = $"../../fade/AnimationPlayer"

var depletion_timer: Timer
var depletion_rate: float = 1.0
var depletion_interval: float = 1.0
var base_light_energy: float = 1.0
var flicker_strength: float = 0.1
var flicker_speed: float = 10.0
var is_fire_alive: bool = true
var doll_tween: Tween
var current_doll_burning: int = 0
var is_burning_doll: bool = false

func _ready() -> void:
	fire_health.value = 100
	base_light_energy = camp_fire.light_energy
	doll.position.y = 0.2
	doll.visible = false
	campfire_audio.play()
	
	depletion_timer = Timer.new()
	depletion_timer.wait_time = depletion_interval
	depletion_timer.timeout.connect(_on_depletion_timeout)
	add_child(depletion_timer)
	fire_health_sprite.hide()

func _process(_delta: float) -> void:
	if not Global.fire_progress_pause and depletion_timer.is_stopped():
		depletion_timer.start()
	update_fire_effects()

func update_fire_effects():
	if not is_fire_alive:
		return
	
	var flicker = sin(Time.get_ticks_msec() * 0.01 * flicker_speed) * flicker_strength
	var random_flicker = randf_range(-flicker_strength * 0.5, flicker_strength * 0.5)
	camp_fire.light_energy = base_light_energy + flicker + random_flicker
	
	var health_ratio = fire_health.value / 100.0
	var particle_scale = lerp(0.5, 1.0, health_ratio)
	flames.scale = Vector3(particle_scale, particle_scale, particle_scale)
	campfire_audio.volume_db = lerp(-20.0, 0.0, health_ratio)
	camp_fire.light_energy *= health_ratio
	
	if fire_health.value <= 0 and is_fire_alive:
		kill_fire()

func _on_depletion_timeout():
	if fire_health.value > 0 and not Global.fire_progress_pause and is_fire_alive:
		fire_health.value -= depletion_rate
		fire_health.value = max(0, fire_health.value)

func kill_fire():
	is_fire_alive = false
	camp_fire.light_energy = 0
	flames.emitting = false
	campfire_audio.stop()
	fade_anim.play("fade_out")
	await get_tree().create_timer(3.0).timeout
	reset_game_state()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func reset_game_state():
	Global.game_started = false
	Global.doll_1_collected = false
	Global.doll_2_collected = false
	Global.doll_3_collected = false
	Global.doll_4_collected = false
	Global.doll_1_burned = false
	Global.doll_2_burned = false
	Global.doll_3_burned = false
	Global.doll_4_burned = false
	Global.sticks_collected = 0
	Global.sticks_used = 0
	Global.fire_progress_pause = false

func revive_fire():
	is_fire_alive = true
	flames.emitting = true
	fire_health.value = 15
	campfire_audio.play()
	add_items_audio.play()

func burn_doll_animation(doll_number: int):
	if doll_tween:
		doll_tween.kill()
	
	is_burning_doll = true
	doll.position.y = 0.2
	doll.visible = true
	doll_burn_audio.play()
	
	doll_tween = create_tween()
	doll_tween.set_ease(Tween.EASE_IN_OUT)
	doll_tween.set_trans(Tween.TRANS_SINE)
	doll_tween.tween_callback(start_jitter_effect)
	doll_tween.tween_interval(2.0)
	doll_tween.tween_callback(stop_jitter_effect)
	doll_tween.tween_property(doll, "position:y", -0.01, 2.0)
	doll_tween.tween_callback(func(): 
		doll.visible = false
		is_burning_doll = false
		fire_health.value += 5
		fire_health.value = min(fire_health.value, 100)
		add_items_audio.play()
		emit_doll_burned_signal(doll_number)
	)

func start_jitter_effect():
	set_process(true)

func stop_jitter_effect():
	set_process(false)

func emit_doll_burned_signal(doll_number: int):
	match doll_number:
		1: 
			Global.doll_1_burned = true
			doll_1_burned.emit()
			doll_burned.play()
		2: 
			Global.doll_2_burned = true
			doll_2_burned.emit()
			doll_burned.play()
		3: 
			Global.doll_3_burned = true
			doll_3_burned.emit()
			doll_burned.play()
		4: 
			Global.doll_4_burned = true
			doll_4_burned.emit()
			doll_burned.play()

func has_collected_dolls() -> bool:
	return (Global.doll_1_collected and not Global.doll_1_burned) or \
		   (Global.doll_2_collected and not Global.doll_2_burned) or \
		   (Global.doll_3_collected and not Global.doll_3_burned) or \
		   (Global.doll_4_collected and not Global.doll_4_burned)

func check_and_burn_dolls():
	if Global.doll_1_collected and not Global.doll_1_burned:
		burn_doll_animation(1)
		return
	if Global.doll_2_collected and not Global.doll_2_burned:
		burn_doll_animation(2)
		return
	if Global.doll_3_collected and not Global.doll_3_burned:
		burn_doll_animation(3)
		return
	if Global.doll_4_collected and not Global.doll_4_burned:
		burn_doll_animation(4)
		return

@warning_ignore("unused_parameter")
func _on_interacted(body: Variant, interaction_type: Variant) -> void:
	if has_collected_dolls() and not is_burning_doll:
		check_and_burn_dolls()
		return
	
	if Global.sticks_collected > 0 and fire_health.value <= 80 and is_fire_alive and not is_burning_doll:
		Global.sticks_collected -= 1
		Global.sticks_used += 1
		fire_health.value += 20
		fire_health.value = min(fire_health.value, 100)
		add_items_audio.play()
		if not is_fire_alive:
			revive_fire()
