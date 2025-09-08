@tool
extends RefCounted

var script_path : String
var todos : Array

func _init(script_path: String, todos: Array):
	self.script_path = script_path
	self.todos = todos

func get_short_path() -> String:
	var temp_array := script_path.rsplit('/', false, 1)
	var short_path : String
	if not temp_array.size() > 1:
		short_path = "(!)" + temp_array[0]
	else:
		short_path = temp_array[1]
	return short_path
