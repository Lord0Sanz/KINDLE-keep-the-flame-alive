extends Interactables

@onready var doll: MeshInstance3D = $"../grave/doll"
@onready var note_2: MeshInstance3D = $"../note_2"
signal grave_2
@onready var scream: AudioStreamPlayer3D = $"../scream"

@warning_ignore("unused_parameter")
func _on_interacted(body: Variant, interaction_type: Variant) -> void:
	Global.grave_2_collection = true
	Global.doll_2_collected = true
	doll.hide()
	note_2.hide()
	scream.play()
	emit_signal("grave_2")
	queue_free()
