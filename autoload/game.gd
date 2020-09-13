extends Node

# scenes which are prevented to be loaded
const scenes_denylist = [
	"res://scenes/main.tscn"
]

var main: Main


func _init():
	pass


func init(main_scene):
	main = main_scene


func _ready():
	if main == null:
		call_deferred("_force_load")


func _force_load():
	""" Needed when starting a specific scene with Play Scene with F6,
	instead of running the whole game"""
	# prepare vars
	var played_scene = get_tree().current_scene
	var root = get_node("/root")
	# load main.tscn
	main = load("res://scenes/main.tscn").instance()
	# prevent fade in. When loading a specific scene you probably want to access your game as fast as possible
	main.initial_fade_active = false
	root.remove_child(played_scene)
	root.add_child(main)
	# reparent played scene under main_node
	main.active_scene_container.get_child(0).queue_free()
	main.active_scene_container.add_child(played_scene)
	played_scene.owner = main


func change_scene(new_scene, params= {}):
	var current_scene = main.active_scene_container.get_child(0)
	var transitions: Transitions = main.transitions

	# prevent inputs  during scene change
	get_tree().paused = true
		
	if new_scene in scenes_denylist:
		print_debug("WARNING: ", new_scene, " is in the denylist. Loading a default scene")
		new_scene = "res://scenes/menu/menu.tscn"

	var scn = load(new_scene)
	transitions.fade_in()
	yield(transitions.anim, "animation_finished")
	current_scene.queue_free()
	var instanced_scn = scn.instance()
	main.active_scene_container.add_child(instanced_scn)
	# artificially wait some time in order to have a gentle game transition
	# TODO: do this only if load time < 0.5s
	yield(get_tree().create_timer(0.5), "timeout")
	transitions.fade_out()
	if instanced_scn.has_method("pre_start"):
		instanced_scn.pre_start(params)
	yield(transitions.anim, "animation_finished")
	get_tree().paused = false
	if instanced_scn.has_method("start"):
		instanced_scn.start()
