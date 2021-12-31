extends Reference
class_name SceneData

var path: String = ""
var params = null


func _to_string():
	return path + " | params: " + str(params)
