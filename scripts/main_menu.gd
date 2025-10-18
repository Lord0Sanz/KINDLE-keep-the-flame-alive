extends Node3D

@onready var intro: ColorRect = $UI/intro
@onready var title: Label = $UI/intro/title
@onready var ui_buttons: VBoxContainer = $UI/VBoxContainer
@onready var logo: TextureRect = $logo
@onready var click: AudioStreamPlayer = $Click

var story_lines = [
	"I made a stupid bet made before Halloween...",
	"And today is the day to prove myself.",
	"This forest is infamous for cult activities...",
	"and mysterious disappearances.",
	"To make the bet challenging...",
	"I must play by the abided rules of the ritual",
	"They say if the campfire dies out...",
	"I'll be trapped in an endless loop...",
	"forced to relive this night forever.",
	"The fire must be fed, no matter what happens...",
	"or I'll be stuck here with the guardian...",
	"and everything will start again, as they say."
]

var current_line = 0
var current_char = 0
var typewriter_speed = 0.075  # Seconds per character
var typewriter_timer: Timer
var intro_start: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	intro.hide()
	logo.show()
	title.text = ""
	
	# Create typewriter timer (but don't start it yet)
	typewriter_timer = Timer.new()
	typewriter_timer.wait_time = typewriter_speed
	typewriter_timer.timeout.connect(_on_typewriter_timeout)
	typewriter_timer.one_shot = false
	add_child(typewriter_timer)

func _on_play_pressed() -> void:
	ui_buttons.hide()
	click.play()
	intro.show()
	title.show()
	intro_start = true
	
	# Start typewriter effect after play is pressed
	start_typewriter()

func start_typewriter():
	current_line = 0
	current_char = 0
	title.text = ""
	typewriter_timer.start()

func _on_typewriter_timeout():
	if current_line < story_lines.size():
		var line = story_lines[current_line]
		
		if current_char < line.length():
			# Add next character to current line
			title.text += line[current_char]
			current_char += 1
			
			# Special pause for punctuation
			if current_char < line.length():
				var next_char = line[current_char]
				if next_char == "." or next_char == ",":
					typewriter_timer.wait_time = 0.2
				elif next_char == "...":
					typewriter_timer.wait_time = 0.4
				else:
					typewriter_timer.wait_time = typewriter_speed
		else:
			# Current line finished, wait then clear and move to next line
			typewriter_timer.stop()
			await get_tree().create_timer(2.0).timeout  # Wait 2 seconds after line
			
			current_line += 1
			current_char = 0
			title.text = ""  # Clear for next line
			
			if current_line < story_lines.size():
				typewriter_timer.start()  # Start next line
			else:
				# All lines completed
				await get_tree().create_timer(2.0).timeout  # Final wait
				get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		# Story completed
		typewriter_timer.stop()
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
