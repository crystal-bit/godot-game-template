class_name GGT_SceneData
extends RefCounted

var path: String = ""
var params = null


func _to_string():
	return path + " | params: " + str(params)
