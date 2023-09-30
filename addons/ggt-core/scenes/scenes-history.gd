extends RefCounted

var config = preload("res://addons/ggt-core/config.tres")
var _history = []


func add(scene_path: String, params = null):
	var data = SceneData.new()
	data.path = scene_path
	data.params = params
	_history.push_front(data)
	while _history.size() > config.max_history_length:
		_history.pop_back()


func get_last_loaded_scene_data() -> SceneData:
	if _history.size() == 0:
		return null
	return _history[0]
