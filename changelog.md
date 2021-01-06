# Changelog

All notable changes to this project will be documented in this file. 

Versioning follows [calver](https://calver.org/) with the `YYYY-MM-MICRO` scheme.

Inspired by [keepachngelog.com](https://keepachangelog.com/en/1.0.0/).

#### Legend

🟢 Added  
🔵 Changed  
⚪ Fixed  
🟠 Removed  
🔴 Deprecated  

PS: remember to add 2 trailing spaces at the end of each line. This is needed
to trigger new line rendering for markdown.

---

## [Unreleased]

...

## v2021.01.1

🟢 Added `Game.size` to get current viewport game size  
🟢 `Game.change_scene()`: added support for `show_progress_bar`. Usage example:
```gd
Game.change_scene("res://myscene.tscn", {
    'show_progress_bar': true
})
```
🔵 Changed default renderer to GLES2 (better HTML5 compatibility)  
🔵 Changed `initial_fade_active` to `splash_transition_on_start`  
⚪ Fixed many `gdlint` errors (all scripts now follow official GDScript 
code style)  
⚪ Open Sans font filename is now lowercase  
🟠 Removed squarebit pixel art font

## v2020.12.1

🟢 Added changelog.md  
⚪ Fixed error when loading a new scene  
⚪ Fixed HTML5: crash on multithread loading
[#15](https://github.com/crystal-bit/godot-game-template/issues/15)  

## v2020.12.0

Initial version.
