# Godot Game Template

Opinionated game template for quick development.

## Features

- Mouse, keyboard and joypad support for the GUI elements
- Game pause / unpause handling
- Main menu
- `change_scene(scene, params)` function to handle transitions with fade-in/out and input prevention
- project structure: lowercase letters only for file system paths
  - `scenes/`, `entities`
- Automatic build for each commit

## Lower case letters only

To avoid issues when multiple contributors are working on the same project across various
file systems and operating systems.

**Explanation**  
Usually on Windows `player.png` and `PLAYER.png` represents the same file.

This is not true for case-sensitive file systems like ext4.

- https://en.wikipedia.org/wiki/Filename#Letter_case_preservation
- https://en.wikipedia.org/wiki/Filename#Comparison_of_filename_limitations 
