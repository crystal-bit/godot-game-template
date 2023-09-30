extends Resource

@export_group("Transitions")
@export var pause_scenes_on_transitions = true
@export var prevent_input_on_transitions = true
@export_range(0.0, 3000.0, 50.0) var transitions_minimum_duration_ms = 300.0

@export_group("Scenes")
@export_range(0, 10, 1) var max_history_length = 5
