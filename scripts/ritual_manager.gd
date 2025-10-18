extends Node3D

@onready var grave_1: Node3D = $grave_1
@onready var grave_2: Node3D = $grave_2
@onready var grave_3: Node3D = $grave_3
@onready var grave_4: Node3D = $grave_4
@onready var fire_health: Sprite3D = $"../bonfire/fire_health"
@onready var fade_anim: AnimationPlayer = $"../../fade/AnimationPlayer"
@onready var moon: Sprite3D = $"../../moon"

var grave_tweens: Array[Tween] = []
var current_grave_to_show: int = 1

func _ready():
	grave_1.position.y = -0.3
	grave_2.position.y = -0.3
	grave_3.position.y = -0.3
	grave_4.position.y = -0.3

func _on_grave_1_grave_1() -> void:moon.modulate = Color(1.0, 0.8, 0.8)
func _on_grave_2_grave_2() -> void:pass
func _on_grave_3_grave_3() -> void:pass
func _on_grave_4_grave_4() -> void:moon.modulate = Color(1.0, 0.2, 0.2)

func _on_bonfire_doll_1_burned() -> void:
	current_grave_to_show = 2
	rise_grave(grave_2, 2)

func _on_bonfire_doll_2_burned() -> void:
	current_grave_to_show = 3
	rise_grave(grave_3, 3)
	moon.modulate = Color(1.0, 0.6, 0.6)

func _on_bonfire_doll_3_burned() -> void:
	current_grave_to_show = 4
	rise_grave(grave_4, 4)
	moon.modulate = Color(1.0, 0.4, 0.4)

func _on_bonfire_doll_4_burned() -> void:
	moon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	fire_health.hide()
	Global.fire_progress_pause = true
	fade_anim.play("fade_out")
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://scenes/ending.tscn")

func _on_rule_page_start_game() -> void:
	rise_grave(grave_1, 1)

func rise_grave(grave: Node3D, _grave_number: int):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(grave, "position:y", 0.0, 1.5)
	grave_tweens.append(tween)
