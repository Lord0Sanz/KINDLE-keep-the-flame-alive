extends Node3D

@onready var title: Label = $intro/title

var story_lines = [
	"I survived the ritual... barely.",
	"Somehow, I escaped without trapping myself in the loop.",
	"I rushed out of that cursed forest as fast as I could...",
	"My luck guided me to a nearby town where the authorities found me.",
	"They questioned me for hours about what I witnessed...",
	"About the cult, the missing people, and the guardian.",
	"I will never make a stupid bet like that again...",
	"Some things are better left undisturbed.",
	"Thank you for playing\nKINDLE\nKeep the flame alive\nA game by\nPROJEKT SANS STUDIOS",
	"This game was made for the Theme\nIGNITE\nFor GIC JAM 4",
	"ASSETS\nPROJEKT SANS STUDIOS\nElbolilloduro",
	"AUDIO & SFX\nPIXABAY",
	"STORY & PROGRAMMING\nShubhayu K\n(lead dev)",
	"© 2025 PROJEKT SANS STUDIOS\nAll Rights Reserved"
]
var current_line = 0
var current_char = 0
var typewriter_speed = 0.075  # Seconds per character
var typewriter_timer: Timer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	title.text = ""
	
	# Create typewriter timer
	typewriter_timer = Timer.new()
	typewriter_timer.wait_time = typewriter_speed
	typewriter_timer.timeout.connect(_on_typewriter_timeout)
	typewriter_timer.one_shot = false
	add_child(typewriter_timer)
	
	# Start typewriter effect
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
			await get_tree().create_timer(2.5).timeout  # Wait 2.5 seconds after line
			
			current_line += 1
			current_char = 0
			title.text = ""  # Clear for next line
			
			if current_line < story_lines.size():
				typewriter_timer.start()  # Start next line
			else:
				# All lines completed
				await get_tree().create_timer(3.0).timeout  # Final wait
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		# Story completed
		typewriter_timer.stop()
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
