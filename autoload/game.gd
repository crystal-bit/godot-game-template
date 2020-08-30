extends Node

# scenes which are prevented to be loaded
const scenes_denylist = [
	"res://scenes/main.tscn"
]

var main


func _init():
	pass


func _ready():
	if main == null:
		call_deferred("_force_load")


func _force_load():
	""" Needed when starting a specific scene with Play Scene with F6,
	instead of running the whole game"""
	# prepare vars
	var played_scene = get_tree().current_scene
	print(played_scene, played_scene.name)
	var root = get_node("/root")
	print(root, root.name)

	# load Main.tscn
	main = load("res://scenes/main.tscn").instance()
	root.remove_child(played_scene)
	root.add_child(main)
	# reparent played scene under main_node
	main.active_scene.get_child(0).queue_free()
	main.active_scene.add_child(played_scene)
	played_scene.owner = main


func init(main_scene):
	main = main_scene


func change_scene(new_scene):
	if new_scene in scenes_denylist:
		print_debug("WARNING: ", new_scene, " is in the denylist. Loading a default scene")
		new_scene = "res://scenes/menu/menu.tscn"

	main.anims.play("fade-to-black")
	yield(main.anims, "animation_finished")
	get_tree().paused = false
	main.active_scene.get_child(0).queue_free()
	var scn = load(new_scene)
	main.active_scene.add_child(scn.instance())
	main.anims.play("fade-from-black")
	yield(main.anims, "animation_finished")


func flash():
	main.anims.play("flash")
