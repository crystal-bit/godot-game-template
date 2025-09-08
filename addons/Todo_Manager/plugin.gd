@tool
extends EditorPlugin

const DockScene := preload("res://addons/Todo_Manager/UI/Dock.tscn")
const Dock := preload("res://addons/Todo_Manager/Dock.gd")
const Todo := preload("res://addons/Todo_Manager/todo_class.gd")
const TodoItem := preload("res://addons/Todo_Manager/todoItem_class.gd")

var _dockUI : Dock

class TodoCacheValue:
	var todos: Array
	var last_modified_time: int
	
	func _init(todos: Array, last_modified_time: int):
		self.todos = todos
		self.last_modified_time = last_modified_time

var todo_cache : Dictionary # { key: script_path, value: TodoCacheValue } 
var remove_queue : Array
var combined_pattern : String
var cased_patterns : Array[String]

var refresh_lock := false # makes sure _on_filesystem_changed only triggers once


func _enter_tree() -> void:
	_dockUI = DockScene.instantiate() as Control
	add_control_to_bottom_panel(_dockUI, "TODO")
	get_editor_interface().get_resource_filesystem().connect("filesystem_changed", 
			_on_filesystem_changed)
	get_editor_interface().get_file_system_dock().connect("file_removed", queue_remove)
	get_editor_interface().get_script_editor().connect("editor_script_changed",
			_on_active_script_changed)
	_dockUI.plugin = self

	combined_pattern = combine_patterns(_dockUI.patterns)
	find_tokens_from_path(find_scripts())
	_dockUI.build_tree()


func _exit_tree() -> void:
	_dockUI.create_config_file()
	remove_control_from_bottom_panel(_dockUI)
	_dockUI.free()


func queue_remove(file: String):
	for i in _dockUI.todo_items.size() - 1:
		if _dockUI.todo_items[i].script_path == file:
			_dockUI.todo_items.remove_at(i)


func find_tokens_from_path(scripts: Array[String]) -> void:
	for script_path in scripts:
		var file := FileAccess.open(script_path, FileAccess.READ)
		var contents := file.get_as_text()
		if script_path.ends_with(".tscn"):
			handle_built_in_scripts(contents, script_path)
		else:
			find_tokens(contents, script_path)


func handle_built_in_scripts(contents: String, resource_path: String):
	var s := contents.split("sub_resource type=\"GDScript\"")
	if s.size() <= 1:
		return
	for i in range(1, s.size()):
		var script_components := s[i].split("script/source")
		var script_name = script_components[0].substr(5, 14)
		find_tokens(script_components[1], resource_path + "::" + script_name)


func find_tokens(text: String, script_path: String) -> void:
	var cached_todos = get_cached_todos(script_path)
	if cached_todos.size() != 0:
#		var i := 0
#		for todo_item in _dockUI.todo_items:
#			if todo_item.script_path == script_path:
#				_dockUI.todo_items.remove_at(i)
#			i += 1
		var todo_item := TodoItem.new(script_path, cached_todos)
		_dockUI.todo_items.append(todo_item)
	else:
		var regex = RegEx.new()
	#	if regex.compile("#\\s*\\bTODO\\b.*|#\\s*\\bHACK\\b.*") == OK:
		if regex.compile(combined_pattern) == OK:
			var result : Array[RegExMatch] = regex.search_all(text)
			if result.is_empty():
				for i in _dockUI.todo_items.size():
					if _dockUI.todo_items[i].script_path == script_path:
						_dockUI.todo_items.remove_at(i)
				return # No tokens found
			var match_found : bool
			var i := 0
			for todo_item in _dockUI.todo_items:
				if todo_item.script_path == script_path:
					match_found = true
					var updated_todo_item := update_todo_item(todo_item, result, text, script_path)
					_dockUI.todo_items.remove_at(i)
					_dockUI.todo_items.insert(i, updated_todo_item)
					break
				i += 1
			if !match_found:
				_dockUI.todo_items.append(create_todo_item(result, text, script_path))


func create_todo_item(regex_results: Array[RegExMatch], text: String, script_path: String) -> TodoItem:
	var todo_item = TodoItem.new(script_path, [])
	todo_item.script_path = script_path
	var last_line_number := 0
	var lines := text.split("\n")
	for r in regex_results:
		var new_todo : Todo = create_todo(r.get_string(), script_path)
		new_todo.line_number = get_line_number(r.get_string(), text, last_line_number)
		# GD Multiline comment
		var trailing_line := new_todo.line_number
		var should_break = false
		while trailing_line < lines.size() and lines[trailing_line].dedent().begins_with("#"):
			for other_r in regex_results:
				if lines[trailing_line] in other_r.get_string():
					should_break = true
					break
			if should_break:
				break
			
			new_todo.content += "\n" + lines[trailing_line]
			trailing_line += 1
		
		last_line_number = new_todo.line_number
		todo_item.todos.append(new_todo)
	cache_todos(todo_item.todos, script_path)
	return todo_item


func update_todo_item(todo_item: TodoItem, regex_results: Array[RegExMatch], text: String, script_path: String) -> TodoItem:
	todo_item.todos.clear()
	var lines := text.split("\n")
	for r in regex_results:
		var new_todo : Todo = create_todo(r.get_string(), script_path)
		new_todo.line_number = get_line_number(r.get_string(), text)
		# GD Multiline comment
		var trailing_line := new_todo.line_number
		var should_break = false
		while trailing_line < lines.size() and lines[trailing_line].dedent().begins_with("#"):
			for other_r in regex_results:
				if lines[trailing_line] in other_r.get_string():
					should_break = true
					break
			if should_break:
				break
			
			new_todo.content += "\n" + lines[trailing_line]
			trailing_line += 1
		todo_item.todos.append(new_todo)
	return todo_item


func get_line_number(what: String, from: String, start := 0) -> int:
	what = what.split('\n')[0] # Match first line of multiline C# comments
	var temp_array := from.split('\n')
	var lines := Array(temp_array)
	var line_number# = lines.find(what) + 1
	for i in range(start, lines.size()):
		if what in lines[i]:
			line_number = i + 1 # +1 to account of 0-based array vs 1-based line numbers
			break
		else:
			line_number = 0 # This is an error
	return line_number


func _on_filesystem_changed() -> void:
	if !refresh_lock:
		if _dockUI.auto_refresh:
			refresh_lock = true
			_dockUI.get_node("Timer").start()
			rescan_files(false)


func find_scripts() -> Array[String]:
	var scripts : Array[String]
	var directory_queue : Array[String]
	var dir := DirAccess.open("res://")
	if dir.get_open_error() == OK:
		get_dir_contents(dir, scripts, directory_queue)
	else:
		printerr("TODO_Manager: There was an error during find_scripts()")
	
	while not directory_queue.is_empty():
		if dir.change_dir(directory_queue[0]) == OK:
			get_dir_contents(dir, scripts, directory_queue)
		else:
			printerr("TODO_Manager: There was an error at: " + directory_queue[0])
		directory_queue.pop_front()
	
	return scripts


func cache_todos(todos: Array, script_path: String) -> void:
	var last_modified_time = FileAccess.get_modified_time(script_path)
	todo_cache[script_path] = TodoCacheValue.new(todos, last_modified_time)


func get_cached_todos(script_path: String) -> Array:
	if todo_cache.has(script_path) and !script_path.contains("tscn::"):
		var cached_value: TodoCacheValue = todo_cache[script_path]
		if cached_value.last_modified_time == FileAccess.get_modified_time(script_path):
			
			return cached_value.todos
	return []

func get_dir_contents(dir: DirAccess, scripts: Array[String], directory_queue: Array[String]) -> void:
	dir.include_navigational = false
	dir.include_hidden = false
	dir.list_dir_begin()
	var file_name : String = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			if file_name == ".import" or file_name == ".mono": # Skip .import folder which should never have scripts
				pass
			else:
				directory_queue.append(dir.get_current_dir().path_join(file_name))
		else:
			if file_name.ends_with(".gd") or file_name.ends_with(".cs") \
			or file_name.ends_with(".c") or file_name.ends_with(".cpp") or file_name.ends_with(".h") \
			or ((file_name.ends_with(".tscn") and _dockUI.builtin_enabled)):
				scripts.append(dir.get_current_dir().path_join(file_name))
		file_name = dir.get_next()


func rescan_files(clear_cache: bool) -> void:
	_dockUI.todo_items.clear()
	if clear_cache:
		todo_cache.clear()
	combined_pattern = combine_patterns(_dockUI.patterns)
	find_tokens_from_path(find_scripts())
	_dockUI.build_tree()


func combine_patterns(patterns: Array) -> String:
	# Case Sensitivity
	cased_patterns = []
	for pattern in patterns:
		if pattern[2] == _dockUI.CASE_INSENSITIVE:
			cased_patterns.append(pattern[0].insert(0, "((?i)") + ")")
		else: 
			cased_patterns.append("(" + pattern[0] + ")")
	
	if patterns.size() == 1:
		return cased_patterns[0]
	else:
		var pattern_string := "((\\/\\*)|(#|\\/\\/))\\s*("
		for i in range(patterns.size()):
			if i == 0:
				pattern_string += cased_patterns[i]
			else:
				pattern_string += "|" + cased_patterns[i]
		pattern_string += ")(?(2)[\\s\\S]*?\\*\\/|.*)"
		return pattern_string


func create_todo(todo_string: String, script_path: String) -> Todo:
	var todo := Todo.new()
	var regex = RegEx.new()
	for pattern in cased_patterns:
		if regex.compile(pattern) == OK:
			var result : RegExMatch = regex.search(todo_string)
			if result:
				todo.pattern = pattern
				todo.title = result.strings[0]
			else:
				continue
		else:
			printerr("Error compiling " + pattern)
	
	todo.content = todo_string
	todo.script_path = script_path
	return todo


func _on_active_script_changed(script) -> void:
	if _dockUI:
		if _dockUI.tabs.current_tab == 1:
			_dockUI.build_tree()
