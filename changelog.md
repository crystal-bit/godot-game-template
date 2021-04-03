# Changelog

All notable changes to this project will be documented in this file.

Versioning follows [calver](https://calver.org/) with the `YYYY-MM-MICRO` scheme.

Inspired by [keepachngelog.com](https://keepachangelog.com/en/1.0.0/).

#### Legend

🟢 Added\
🔵 Changed\
⚪ Fixed\
🟠 Removed\
🔴 Deprecated

PS: remember to add 2 trailing spaces at the end of each line (or a single `/` symbol).\
This is needed to trigger new line rendering for markdown.

---

## [dev branch / Unreleased]

...

## v2021.04.0

🟢 Added version number in main menu
🔵 `Game.change_scene` hides the progress bar by default. If you want to show
loading progress, pass `{show_progress_bar = true}` as param\
🔵 Scene tree not automatically paused anymore on scene change (input will still be captured to prevent messing with scenes during transitions)\
⚪ Fixed issue [#17][i17]: optimized multithread loading\
⚪ Fixed issue [#35][i35]: optimized single thread loading\
⚪ Fixed issue [#32][i32]: crash when playing a specific scene\
⚪ Fixed issue [#30][i30]: hide exit button on HTML5\
⚪ `Game.size` correctly initialized also in `_ready` functions\
🟠 `Gameplay.tscn`: Removed Player class and scene

[i17]: https://github.com/crystal-bit/godot-game-template/issues/17
[i35]: https://github.com/crystal-bit/godot-game-template/issues/35
[i32]: https://github.com/crystal-bit/godot-game-template/issues/32
[i30]: https://github.com/crystal-bit/godot-game-template/issues/30

## v2021.01.1

🟢 Added `Game.size` to get current viewport game size\
🟢 `Game.change_scene()`: added support for `show_progress_bar`. Usage example:
```gd
Game.change_scene("res://myscene.tscn", {
    'show_progress_bar': true
})
```
🔵 Changed default renderer to GLES2 (better HTML5 compatibility)\
🔵 Changed `initial_fade_active` to `splash_transition_on_start`\
⚪ Fixed many `gdlint` errors (all scripts now follow official GDScript\
code style)
⚪ Open Sans font filename is now lowercase\
🟠 Removed squarebit pixel art font

## v2020.12.1

🟢 Added changelog.md\
⚪ Fixed error when loading a new scene\
⚪ Fixed HTML5: crash on multithread loading [#15](https://github.com/crystal-bit/godot-game-template/issues/15)

## v2020.12.0

Initial version.
