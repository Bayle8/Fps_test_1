extends HSlider

@export var audio_bus_name: String = "Master"

var audio_bus_id
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	# slider standard values
	min_value = 0.0
	max_value = 1.0
	step = 0.001
	var current_db = AudioServer.get_bus_volume_db(audio_bus_id)
	value = db_to_linear(current_db)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_value_changed(value: float) -> void:
	if audio_bus_id == -1: 
		return
	var db = linear_to_db(value)
	print("Lo slider si muove! Valore DB: ", db)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
