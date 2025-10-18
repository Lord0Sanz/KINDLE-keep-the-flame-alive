extends Interactables

@onready var stick_mesh: Node3D = $".."
@onready var item_pick: AudioStreamPlayer = $"../ItemPick"

@warning_ignore("unused_parameter")
func _on_interacted(body: Variant, interaction_type: Variant) -> void:
	item_pick.play()
	Global.sticks_collected += 1
	await get_tree().create_timer(0.25).timeout
	stick_mesh.queue_free()
