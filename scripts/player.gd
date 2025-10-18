extends CharacterBody3D

@onready var cam: Camera3D = $Camera3D
@onready var lighter_cap: MeshInstance3D = $Camera3D/lighter/lighter_base/lighter_cap
@onready var light_source: OmniLight3D = $Camera3D/lighter/lighter_base/light_source
@onready var flame_texture: Node3D = $Camera3D/lighter/lighter_base/flame/flame_texture
@onready var step_audio: AudioStreamPlayer = $Step
@onready var lighter_audio: AudioStreamPlayer = $Camera3D/lighter/lighter_base/Lighter

const WALK_SPEED = 2.0
const SPRINT_SPEED = 5.0
const MOUSE_SENSITIVITY = 0.002
const LIGHT_ENERGY = 5.0
const LIGHT_RANGE = 3.0
const FLICKER_SPEED = 10.0
const FLICKER_STRENGTH = 0.3
const FLAME_MIN_SCALE = 0.1
const FLAME_MAX_SCALE = 1.0

var camera_rotation: Vector2 = Vector2.ZERO
var is_lighter_open = false
var lighter_tween: Tween
var light_tween: Tween
var is_light_on = false
var base_light_energy = 0.0
var movement_paused: bool = false
var step_cooldown: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	light_source.light_energy = 0.0
	light_source.visible = false
	flame_texture.scale = Vector3(FLAME_MIN_SCALE, FLAME_MIN_SCALE, FLAME_MIN_SCALE)

func _input(event: InputEvent) -> void:
	if movement_paused:
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera_rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		camera_rotation.x = clamp(camera_rotation.x, -1.5, 1.5)
		cam.rotation.x = camera_rotation.x
		rotation.y = camera_rotation.y
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("lighter"):
		toggle_lighter_cap()

func toggle_lighter_cap() -> void:
	if lighter_tween:
		lighter_tween.kill()
	
	lighter_tween = create_tween()
	lighter_tween.set_ease(Tween.EASE_OUT)
	lighter_tween.set_trans(Tween.TRANS_BACK)
	
	if is_lighter_open:
		lighter_tween.tween_property(lighter_cap, "rotation_degrees", Vector3(0, 0, 0), 0.4)
		turn_off_light()
	else:
		lighter_tween.tween_property(lighter_cap, "rotation_degrees", Vector3(0, 0, -80), 0.4)
		turn_on_light()
		lighter_audio.play()
	
	is_lighter_open = !is_lighter_open

func turn_on_light() -> void:
	is_light_on = true
	light_source.visible = true
	
	if light_tween:
		light_tween.kill()
	
	light_tween = create_tween()
	
	var start_energy = LIGHT_ENERGY * 1.5
	light_tween.tween_property(light_source, "light_energy", start_energy, 0.05)
	light_tween.tween_property(light_source, "light_energy", LIGHT_ENERGY * 0.5, 0.05)
	light_tween.tween_property(light_source, "light_energy", LIGHT_ENERGY, 0.1)
	
	light_tween.parallel().tween_property(flame_texture, "scale", 
		Vector3(FLAME_MAX_SCALE, FLAME_MAX_SCALE, FLAME_MAX_SCALE), 0.2)
	
	base_light_energy = LIGHT_ENERGY

func turn_off_light() -> void:
	is_light_on = false
	
	if light_tween:
		light_tween.kill()
	
	light_tween = create_tween()
	light_tween.set_ease(Tween.EASE_OUT)
	
	light_tween.tween_property(light_source, "light_energy", LIGHT_ENERGY * 0.3, 0.05)
	light_tween.tween_property(light_source, "light_energy", LIGHT_ENERGY * 0.8, 0.03)
	light_tween.tween_property(light_source, "light_energy", 0.0, 0.1)
	
	light_tween.parallel().tween_property(flame_texture, "scale", 
		Vector3(FLAME_MIN_SCALE, FLAME_MIN_SCALE, FLAME_MIN_SCALE), 0.15)
	
	light_tween.tween_callback(func(): 
		light_source.visible = false
	)

func pause_movement():
	movement_paused = true
	velocity = Vector3.ZERO

func resume_movement():
	movement_paused = false

func _physics_process(delta: float) -> void:
	velocity.y = 0
	
	if step_cooldown > 0:
		step_cooldown -= delta
	
	if movement_paused:
		move_and_slide()
		return
	
	var current_speed: float
	current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		direction = (transform.basis.z * input_dir.y + transform.basis.x * input_dir.x).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if is_on_floor() and step_cooldown <= 0:
			step_audio.play()
			if Input.is_action_pressed("sprint"):
				step_cooldown = 0.3
			else:
				step_cooldown = 0.5
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()
	
	if is_light_on:
		var flicker = sin(Time.get_ticks_msec() * 0.01 * FLICKER_SPEED) * FLICKER_STRENGTH
		var random_flicker = randf_range(-FLICKER_STRENGTH * 0.5, FLICKER_STRENGTH * 0.5)
		light_source.light_energy = base_light_energy + flicker + random_flicker
		light_source.omni_range = LIGHT_RANGE + sin(Time.get_ticks_msec() * 0.005) * 0.2
		
		var flame_flicker = randf_range(0.95, 1.05)
		flame_texture.scale = Vector3(FLAME_MAX_SCALE * flame_flicker, FLAME_MAX_SCALE * flame_flicker, FLAME_MAX_SCALE * flame_flicker)
