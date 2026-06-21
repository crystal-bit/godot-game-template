extends Node


func _ready() -> void:
	var scene_data = GGT.get_current_scene_data()
	print("[GGT/Gameplay] scene params are ", scene_data.params)

	if DebugMenu != null: # need to check as DebugMenu is not available on release builds
		DebugMenu.update_settings_label() # this is just to show the correct 3D scaling option in the advanced section

	if GGT.is_changing_scene(): # this will be false if starting the scene with "Run current scene" or F6 shortcut
		await GGT.scene_transition_finished

	print("[GGT/Gameplay] scene transition animation finished")
