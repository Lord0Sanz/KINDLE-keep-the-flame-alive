extends RayCast3D

@onready var prompt: Label = $prompt

func _physics_process(_delta: float) -> void:
	prompt.text = ""
	
	if is_colliding():
		var collider = get_collider()
		if collider is Interactables:
			prompt.text = collider.get_prompts()
			
			if Input.is_action_just_pressed("interact"):
				collider.interact_primary(get_parent())
