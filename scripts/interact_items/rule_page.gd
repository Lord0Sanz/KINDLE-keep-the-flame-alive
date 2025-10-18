extends Interactables

@onready var rule_page: Area3D = $"."
@onready var fire_health: Sprite3D = $"../../bonfire/fire_health"

signal start_game

@warning_ignore("unused_parameter")
func _on_interacted(body: Variant, interaction_type: Variant) -> void:
	emit_signal("start_game")
	Global.fire_progress_pause = false
	Global.game_started = true
	fire_health.show()
	rule_page.queue_free()
	
