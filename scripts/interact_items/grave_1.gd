extends Interactables

@onready var doll: MeshInstance3D = $"../grave/doll"
@onready var note_1: MeshInstance3D = $"../note_1"
signal grave_1
@onready var scream: AudioStreamPlayer3D = $"../scream"

@warning_ignore("unused_parameter")
func _on_interacted(body: Variant, interaction_type: Variant) -> void:
	Global.grave_1_collection = true
	Global.doll_1_collected = true
	doll.hide()
	note_1.hide()
	scream.play()
	emit_signal("grave_1")
	queue_free()
