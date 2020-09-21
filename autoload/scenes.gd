extends Node

# scenes which are prevented to be loaded
const scenes_denylist = [
	"res://scenes/main.tscn"
]
# scene which is loaded instead of a denied scene
const fallback_scene = "res://scenes/menu/menu.tscn" 
const minimum_load_time = 300 #ms

var main: Main


func _set_main_node(node: Main):
	main = node


func _ready():
	if main == null:
		call_deferred("_force_load")


func _force_load():
	""" Needed when starting a specific scene with Play Scene with F6,
	instead of starting the game from main.tscn"""
	# prepare vars
	var played_scene = get_tree().current_scene
	var root = get_node("/root")
	# load main.tscn
	main = load("res://scenes/main.tscn").instance()
	# when playing a specific scene (F6) you want to access your game as fast as possible
	main.initial_fade_active = false
	root.remove_child(played_scene)
	root.add_child(main)
	# reparent played scene under main_node
	main.active_scene_container.get_child(0).queue_free()
	main.active_scene_container.add_child(played_scene)
	if played_scene.has_method("start"):
		played_scene.start()
	played_scene.owner = main


func _change_scene(new_scene: String, params= {}):
	var current_scene = main.active_scene_container.get_child(0)
	var transitions: Transitions = main.transitions

	# prevent inputs  during scene change
	get_tree().paused = true
		
	if new_scene in scenes_denylist:
		print_debug("WARNING: ", new_scene, " is in the denylist. Loading a default scene")
		new_scene = fallback_scene

	var scn = load(new_scene)
	transitions.fade_in()
	yield(transitions.anim, "animation_finished")
	var loading_start_time = OS.get_ticks_msec()
	current_scene.queue_free()
	var instanced_scn = scn.instance()
	main.active_scene_container.add_child(instanced_scn)
	var load_time = OS.get_ticks_msec() - loading_start_time # ms
	print("🕑🕑🕑🕑🕑🕑{scn} loaded in {elapsed}ms".format({ 'scn': new_scene, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle game transition
	if load_time < minimum_load_time:
		yield(get_tree().create_timer((minimum_load_time - load_time) / 1000.0), "timeout")
	transitions.fade_out()
	if instanced_scn.has_method("pre_start"):
		instanced_scn.pre_start(params)
	yield(transitions.anim, "animation_finished")
	get_tree().paused = false
	if instanced_scn.has_method("start"):
		instanced_scn.start()
