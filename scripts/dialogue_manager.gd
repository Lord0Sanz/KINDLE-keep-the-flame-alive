extends Control

@onready var instruction: Label = $instruction

func _ready():
	instruction.text = "Instructions\nCheck note"

func _process(_delta):
	if not Global.game_started:
		instruction.text = "Instructions\nCheck note"
		return
	
	if Global.doll_4_burned:
		instruction.text = "Instructions\nRitual Complete"
	elif Global.doll_4_collected:
		instruction.text = "Instructions\nBurn the Doll"
	elif Global.doll_3_burned:
		instruction.text = "Instructions\nFind Last Doll"
	elif Global.doll_3_collected:
		instruction.text = "Instructions\nBurn the Doll"
	elif Global.doll_2_burned:
		instruction.text = "Instructions\nFind Third Doll"
	elif Global.doll_2_collected:
		instruction.text = "Instructions\nBurn the Doll"
	elif Global.doll_1_burned:
		instruction.text = "Instructions\nFind Second Doll"
	elif Global.doll_1_collected:
		instruction.text = "Instructions\nBurn the Doll"
	else:
		instruction.text = "Instructions\nFind First Doll"
