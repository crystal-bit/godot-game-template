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

PS: remember to add 2 trailing spaces at the end of each line (or a single `\` symbol).\
This is needed to trigger new line rendering for markdown.

---

## [dev branch / Unreleased]

...

## v2021.12.0

🟢 Added Godot 3.4.2 support \
🟢 Added `Game.restart_scene()` and `Game.restart_scene_with_params(override_params)` \
🟢 Added `scenes._history` to keep track of scenes loading. Currently for internal use only. \
History keeps track of the last 5 scenes and keep track of their parameters. \
🔵 `gameplay.tscn`: use Node as root node instead of Node2D.

## v2021.11.0

🟢 Added Godot 3.4 support \
🔵 Use GLES3 renderer by default. \
Safari 15 supports WebGL2 starting from version 15, this means that
GLES3 should be a safe default right now.

## v2021.06.0

🟢 Added dispatch export. Thanks to vini-guerrero! [#50][pr50] \
⚪ Fixed blurred render on HiDPI devices\
⚪ Fixed [#49][i49]\
🔵 Removed `resources/` top level folder, closes [#12][i12]\

[pr50]: https://github.com/crystal-bit/godot-game-template/pull/50
[i12]: https://github.com/crystal-bit/godot-game-template/issues/12
[i49]: https://github.com/crystal-bit/godot-game-template/issues/49

## v2021.05.0

🟢 **Godot 3.3** support!\
🟢 CI scripts updated. Thanks to Andrea-Miele! [#47][pr47] [#48][pr48] \
🟢 Added pause button for mobile in `gameplay.tscn`. Thanks to Andrea1141 [#44][pr44] \
🟢 `menu.tscn`: added Godot version label

[pr44]: https://github.com/crystal-bit/godot-game-template/pull/44
[pr47]: https://github.com/crystal-bit/godot-game-template/pull/47
[pr48]: https://github.com/crystal-bit/godot-game-template/pull/48

## v2021.04.2

🟢 CI: support for automatic itch.io deploys. Thanks to Andrea-Miele [#41][pr41]

[pr41]: https://github.com/crystal-bit/godot-game-template/pull/41

## v2021.04.1

🟢 CI: support for automatic Android debug build. Thanks to Andrea-Miele https://github.com/crystal-bit/godot-game-template/pull/39 \
🟠 `Main.tscn`: Removed `splash_transition_on_start` property\
🔵 `Transitions` renamed to `Transition`\
🔵 `Transition`: `is_playing` renamed to `is_displayed`\
🔵 `Transition`: refactor animations name

## v2021.04.0

🟢 Added version number in main menu. Thanks to Fahien https://github.com/crystal-bit/godot-game-template/pull/37 \
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
