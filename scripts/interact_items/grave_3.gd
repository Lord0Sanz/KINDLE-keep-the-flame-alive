extends Interactables

@onready var doll: MeshInstance3D = $"../grave/doll"
@onready var note_3: MeshInstance3D = $"../note_3"
signal grave_3
@onready var scream: AudioStreamPlayer3D = $"../scream"

@warning_ignore("unused_parameter")
func _on_interacted(body: Variant, interaction_type: Variant) -> void:
	Global.grave_3_collection = true
	Global.doll_3_collected = true
	doll.hide()
	note_3.hide()
	scream.play()
	emit_signal("grave_3")
	queue_free()
