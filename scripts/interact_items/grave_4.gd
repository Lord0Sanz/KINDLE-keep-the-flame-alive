extends Interactables

@onready var doll: MeshInstance3D = $"../grave/doll"
@onready var note_4: MeshInstance3D = $"../note_4"
signal grave_4
@onready var scream: AudioStreamPlayer3D = $"../scream"

@warning_ignore("unused_parameter")
func _on_interacted(body: Variant, interaction_type: Variant) -> void:
	Global.grave_4_collection = true
	Global.doll_4_collected = true
	doll.hide()
	note_4.hide()
	scream.play()
	emit_signal("grave_4")
	queue_free()
