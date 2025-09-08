## Contributing to TODO Manager
Firstly, thank you for being interested in contributing to the Godot TODO Manager plugin!
TODO Manager has benefitted greatly from enthusiastic users who have suggested new features, noticed bugs, and contributed code to the plugin.

### Code Style Guide
For the sake of clarity, TODO Manager takes advantage of GDScripts optional static typing in most circumstances.
In particular, when declaring variables use colons to infer the type where possible:

`todo := "#TODO"`

If the type is not obvious then explicit typing is desirable:

`items : PoolStringArray = todo.split()`

Typed arguments and return values for functions are required:
```
func example(name: String, amount: int) -> Array:
  # code
  return array_of_names
```

For more info on static typing in Godot please refer to the documentation.
https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/static_typing.html
