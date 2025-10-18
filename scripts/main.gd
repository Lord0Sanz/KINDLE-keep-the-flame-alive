extends Node3D

@onready var player: CharacterBody3D = $player
@onready var fire_health: ProgressBar = $camp_fire/bonfire/fire_health/SubViewport/fire_health

@onready var pausemenu: VBoxContainer = $UI/pausemenu
@onready var resume: Button = $UI/pausemenu/resume
@onready var note: Button = $UI/pausemenu/note
@onready var restart: Button = $UI/pausemenu/restart
@onready var mainmenu: Button = $UI/pausemenu/mainmenu
@onready var controls: Button = $UI/pausemenu/controls
@onready var controls_text: VBoxContainer = $UI/pausemenu/CONTROLS

@onready var notes: Control = $UI/NOTES
@onready var rules: TextureRect = $UI/NOTES/rules
@onready var note_1: TextureRect = $UI/NOTES/note_1
@onready var note_2: TextureRect = $UI/NOTES/note_2
@onready var note_3: TextureRect = $UI/NOTES/note_3
@onready var note_4: TextureRect = $UI/NOTES/note_4

@onready var wolfhowl: AudioStreamPlayer = $Wolfhowl
@onready var click: AudioStreamPlayer = $Click

var is_paused: bool = false
var current_note_page: int = 0
var in_submenu: bool = false
var howl_timer: Timer

func _ready():
	pausemenu.hide()
	notes.hide()
	controls_text.hide()
	
	howl_timer = Timer.new()
	howl_timer.wait_time = randf_range(30.0, 120.0)
	howl_timer.timeout.connect(_on_howl_timeout)
	add_child(howl_timer)
	howl_timer.start()

func _input(event):
	if event.is_action_pressed("pause"):
		if in_submenu:
			_back_to_main_menu()
		else:
			toggle_pause()

func _on_howl_timeout():
	wolfhowl.play()
	howl_timer.wait_time = randf_range(30.0, 120.0)
	howl_timer.start()

func toggle_pause():
	is_paused = !is_paused
	
	if is_paused:
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pausemenu.show()
		player.pause_movement()
		in_submenu = false
	else:
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pausemenu.hide()
		notes.hide()
		controls_text.hide()
		player.resume_movement()
		in_submenu = false

func _back_to_main_menu():
	notes.hide()
	controls_text.hide()
	resume.show()
	note.show()
	restart.show()
	mainmenu.show()
	controls.show()
	in_submenu = false

func _on_safe_zone_body_entered(body: Node3D) -> void:
	if body == player:
		fire_health.show()

func _on_safe_zone_body_exited(body: Node3D) -> void:
	if body == player:
		fire_health.hide()

func _on_resume_pressed() -> void:
	click.play()
	toggle_pause()

func _on_note_pressed() -> void:
	click.play()
	notes.show()
	resume.hide()
	note.hide()
	restart.hide()
	mainmenu.hide()
	controls.hide()
	current_note_page = 0
	update_note_display()
	in_submenu = true

func _on_restart_pressed() -> void:
	click.play()
	get_tree().reload_current_scene()
	Engine.time_scale = 1

func _on_mainmenu_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	Engine.time_scale = 1

func _on_controls_pressed() -> void:
	click.play()
	controls_text.show()
	resume.hide()
	note.hide()
	restart.hide()
	mainmenu.hide()
	controls.hide()
	in_submenu = true

func _on_back_controls_pressed() -> void:
	click.play()
	_back_to_main_menu()

func _on_back_notes_pressed() -> void:
	click.play()
	_back_to_main_menu()

func _on_prev_pressed() -> void:
	click.play()
	current_note_page = max(0, current_note_page - 1)
	update_note_display()

func _on_next_pressed() -> void:
	click.play()
	current_note_page = get_max_available_page()
	update_note_display()

func get_max_available_page() -> int:
	if Global.doll_4_collected:
		return 4
	elif Global.doll_3_collected:
		return 3
	elif Global.doll_2_collected:
		return 2
	elif Global.doll_1_collected:
		return 1
	else:
		return 0

func update_note_display():
	rules.hide()
	note_1.hide()
	note_2.hide()
	note_3.hide()
	note_4.hide()
	
	match current_note_page:
		0: 
			if Global.game_started:
				rules.show()
		1: 
			if Global.doll_1_collected:
				note_1.show()
			else:
				current_note_page = 0
				rules.show()
		2: 
			if Global.doll_2_collected:
				note_2.show()
			else:
				current_note_page = get_max_available_page()
				update_note_display()
		3: 
			if Global.doll_3_collected:
				note_3.show()
			else:
				current_note_page = get_max_available_page()
				update_note_display()
		4: 
			if Global.doll_4_collected:
				note_4.show()
			else:
				current_note_page = get_max_available_page()
				update_note_display()
