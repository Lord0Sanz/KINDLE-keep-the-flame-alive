extends CollisionObject3D
class_name Interactables

signal interacted(body, interaction_type)

@export var primary_prompt_message = "Interact"
@export var primary_prompt_input = "interact"

func get_prompts() -> String:
	var primary_key = ""
	
	for action in InputMap.action_get_events(primary_prompt_input):
		if action is InputEventKey:
			primary_key = action.as_text_physical_keycode()
			break
	
	return primary_prompt_message + "\n[" + primary_key + "]"

func interact_primary(body):
	interacted.emit(body, "primary")
