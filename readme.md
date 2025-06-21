![game-template-overview](https://user-images.githubusercontent.com/6860637/101258948-24c35c80-3726-11eb-8c64-7a201e945f73.png)

> 🌟 You make games, the template handles the boring stuff.

<p>
  <a href="https://godotengine.org/download">
    <img alt="Godot Download badge" src="https://img.shields.io/badge/godot-4.4-blue">
  </a>

  <a href="https://github.com/crystal-bit/godot-game-template/releases">
    <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/crystal-bit/godot-game-template">
  </a>
</p>

**Godot Game Template**, also GGT in short, is a simple generic starter project for Godot games.

Provides a solid base for quick iterations.

It worked well when used by small teams in game jams, but it should be generic
enough to work for mid sized teams as well.

Easily customizable and extendable for jams or larger projects

## Used by

| Logo                                                                                                                                        | Godot | Title                      | Link                                                                                                                                                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ----- | -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ![YouAreUto icon](https://play-lh.googleusercontent.com/lL54YNps-UPuDONDHfy3pmn8_aVUZGMorHJcDArimJWCQKjjNax0QMxpiAWCc5PUPbU=s100-rw)        | 3.4   | **YouAreUto** (2019)       | [Android](https://play.google.com/store/apps/details?id=com.youare.uto), [iOS](https://apps.apple.com/app/brain-game-teaser-youareuto/id1590561597#?platform=iphone), [GitHub](https://github.com/YouAreUto/YouAreUto) |
| ![Defending Todot icon](https://imgur.com/Bn10XAf.png)                                                                                      | 3.2.3 | **Defending Todot** (2020) | [HTML5](https://crystal-bit.github.io/defending-todot/), [GitHub](https://github.com/crystal-bit/defending-todot)                                                                                                      |
| ![Karooto No Gase icon](https://play-lh.googleusercontent.com/sWgjV9dJxa1jKina0mNbU3fGmqA4zuqtRWXfhn_dfEK6reW90GH1uz0wsai1SG898bOZ=s100-rw) | 3.x   | **Karooto No Gase** (2021) | [Android](https://play.google.com/store/apps/details?id=org.calalinta.karootonogase), [Itch.io](https://calalinta.itch.io/)                                                                                            |
| ![Pizza Poison Logo](https://github.com/user-attachments/assets/8f794de0-dcf8-4f8f-b29c-f1c619ba51d2)                                       | 4.3   | **Pizza Poison** (2025)    | [Itch.io](https://spesknight.itch.io/pizza-poison)                                                                                                                                                                     |
| ![Pangolick Quest](https://github.com/user-attachments/assets/80bc19b6-8911-40ad-9214-90f84f9d7dc9)                                         | 4.4.1 | **Pangolick Quest** (2025) | [Itch.io](https://havbit.itch.io/pangolick-quest)                                                                                                                                                                      |

# Features Overview

GGT is composed of multiple parts:

1.  **ggt-core** addon
2.  **ggt-shortcuts** addon
3.  Godot project boilerplate (this repository)

**ggt-core** provides:

- Scene management with transitions and optional progress bar
- Parameter passing between scenes
- Multithreaded scene loading
  - single threaded loading fallback for web exports

**ggt-shortcuts** provides:

- Debug shortcuts mapped to keyboard keys for restart (R), pause (P), quit (Q)
  - if you need those keys for your game, you can easily update the Godot
    Input Map to whatever you like
- Automatic shortcuts removal for release builds

The godot project boilerplate provides:

- GitHub Actions workflows for automatic builds+web deploy on Github Pages after each commit
  - or you can use manual workflow dispatch
  - or you can use a local `release.sh` script to export multiple targets (Windows, Linux, Mac, ...) with a single command
  - or you can export manually from Godot as usual
- A project structure that follows Godot best practices and naming conventions
- Placeholder menu and gameplay scenes with support for keyboard, gamepad or touch inputs
- A preconfigured a global theme for control nodes. Tweak `resources/theme/theme-main.tres` and every control nodes will inherit from it

# Get started

You have 2 options:

## 1. Get started with Github Templates:

1. [Create a new repo using this template](https://github.com/crystal-bit/godot-game-template/generate)
2. Clone the new repository locally
3. Open the project in [Godot](https://godotengine.org/download/) (GDScript)

## 2. Get started with a local project:

1. Go to https://github.com/crystal-bit/godot-game-template/releases
2. Download _Source code (zip)_
3. Unzip the project
4. Open the project in [Godot Engine](https://godotengine.org/download/) (GDScript) and create your game!

# How to...

## Change scene

```gd
Game.change_scene("res://scenes/gameplay/gameplay.tscn")
```

![change_scene](https://user-images.githubusercontent.com/6860637/162567110-026c1979-6237-4255-bb2a-97815fc4b0c4.gif)

## Change scene and show progress bar

```gd
Game.change_scene("res://scenes/gameplay/gameplay.tscn", {
  "show_progress_bar": true
})
```

![progress](https://user-images.githubusercontent.com/6860637/162567097-81b5c54e-1ee5-42b9-a583-60764ecff069.gif)

## Change scene and pass parameters

```gd
var params = {
  "level": 4,
  "skin": "dark"
}
Game.change_scene("res://scenes/gameplay/gameplay.tscn", params)
```

```gd
# gameplay.gd

func pre_start(params):
   print(params.level) # 4
   print(params.skin) # 'dark'
   # setup your scene here
```

## \_ready() vs pre_start() vs start()

They are called in this order:

| method              | description                                                                                                                 |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `_ready()`          | gets called when the graphic transition covers the screen                                                                   |
| `pre_start(params)` | gets called immediately after \_ready, it receives params passed via Game.change_scene(scene_path, params)                  |
| `start`             | it's called as soon as the graphic transition finishes. It's a good place to activate gameplay logic, enemy AI, timers, ... |

## Restart the current scene

```gd
Game.restart_scene() # old params will be reused
```

## Restart the current scene and override params

```gd
var new_params = {
  "level": 5,
}
Game.restart_scene_with_params(new_params)
```

## Center a Node2D into the viewport

```gd
$Sprite.position = Game.size / 2
# Game.size it's just a shortcut to  get_viewport().get_visible_rect().size
```

# addons/ggt-debug-shortcuts

`addons/ggt-debug-shortcuts` is enabled by default and it builds on top of `ggt-core`.

By default it will set these input actions to the project:

| action                    | key   | description                                         |
| ------------------------- | ----- | --------------------------------------------------- |
| "ggt_debug_restart_scene" | KEY_R | Restart the current scene, with the same parameters |
| "ggt_debug_pause_game"    | KEY_P | Pause the tree (useful for quick debug)             |
| "ggt_debug_quit_game"     | KEY_Q | Closes the game                                     |

You can change, remove or add shortcuts in [debug_shortcuts.gd](./addons/ggt-debug-shortcuts/debug_shortcuts.gd).

**These shortcuts work in the editor and in debug builds and are automatically removed on release builds.**

# Conventions and project structure

- `assets/`
  - Contains textures, sprites, sounds, music, fonts, ...
- `builds/`
  - output directory for game builds generated via `release.sh` (ignored by .gitignore and .gdignore)
- `scenes/`
  - Contains Godot scenes (both entities, reusable scenes and "game screen" scenes)
  - Scene folders can contain `.gd` scripts or resources used by the scene

Mostly inspired by the official [Godot Engine guidelines][l1]:

- **snake_case** for files and folders (eg: game.gd, game.tscn)
- **PascalCase** for node names (eg: Game, Player)

[l1]: https://docs.godotengine.org/en/stable/getting_started/workflow/project_setup/project_organization.html#style-guide

### Lower Case file names

This convention avoids having filesystem issues on different platforms. Stick with it
and it will save you time. Read more
[here](https://docs.godotengine.org/en/stable/getting_started/workflow/project_setup/project_organization.html#case-sensitivity):

> Windows and recent macOS versions use case-insensitive filesystems by default,
> whereas Linux distributions use a case-sensitive filesystem by default. This
> can cause issues after exporting a project, since Godot's PCK virtual
> filesystem is case-sensitive. To avoid this, it's recommended to stick to
> snake_case naming for all files in the project (and lowercase characters in
> general).

See also [this PR](https://github.com/godotengine/godot/pull/82957/files) that adds `is_case_sensitive()`.

### Trim whitespaces on save

If every developer on the team is using the built-in Godot Engine text editor I strongly suggest
to activate this option:

- Editor -> Editor Settings -> Text Editor/Behavioud -> Trim Trailing Whitespace on Save

It avoids whitespace changes that may add noise in team work. 

# Export utilities

## `release.sh`

From your project root:

```sh
./release.sh MyGameName # this assumes that you have a "godot" binary/alias in your $PATH
```

Look inside the ./builds/ directory:

```sh
builds
└── MyGameName
    ├── html5
    │   ├── build.log # an export log + build datetime and git hash
    │   ├── index.html
    │   ├── ...
    ├── linux
    │   ├── MyGameName.x86_64
    │   └── build.log
    ├── osx
    │   ├── MyGameName.dmg
    │   └── build.log
    └── windows
        ├── MyGameName.exe
        └── build.log
```

## Github Actions

If you are using Github you can take advantage of:

1. automatic exports for every commit push (see [push-export.yml][ci-push-export])
2. manual exports via Github CI (see [dispatch-export.yml][ci-dispatch] )

[ci-push-export]: ./.github/workflows/push-export.yml
[ci-dispatch]: ./.github/workflows/push-export.yml

You can read more on [Wiki - Continuos Integration][wiki_ci]

[wiki_ci]: https://github.com/crystal-bit/godot-game-template/wiki/1.-Continuous-integration-(via-GitHub-Actions)

# Contributing

If you want to help the project, create games and feel free to get in touch and report any issue.

![Discord](https://img.shields.io/discord/686600734636376102?logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)

You can also join [the Discord server](https://discord.gg/SA6S2Db) (`#godot-game-template` channel).

Before adding new features please open an issue to discuss it with other contributors.

## Contributors

Many features were implemented only thanks to the help of:

- [Andrea-Miele](https://github.com/Andrea-Miele)
- [Fahien](https://github.com/Fahien)
- [Andrea1141](https://github.com/Andrea1141)
- [vini-guerrero](https://github.com/vini-guerrero)
- [idbrii](https://github.com/idbrii)
- [jrassa](https://github.com/jrassa)

Also many tools were already available in the open source community, see the [Thanks](#thanks) section.

# Thanks

- For support & inspiration:
  - All the [contributors](https://github.com/crystal-bit/godot-game-template/graphs/contributors)
  - Crystal Bit community
  - GameLoop.it
  - Godot Engine Italia
  - Godot Engine
- For their work on free and open source software:
  - [aBARICHELLO](https://github.com/aBARICHELLO/godot-ci)
  - [croconut](https://github.com/croconut/godot-multi-builder)
  - [josephbmanley](https://github.com/josephbmanley)
  - [GDQuest](https://github.com/GDquest)
  - [Scony](https://github.com/Scony)
  - [myood](https://github.com/myood)
