#!/bin/sh
set -e

# Set GODOT_BIN to a default value or expect it in PATH
GODOT_BIN="godot"

if ! which "$GODOT_BIN" >/dev/null; then
  echo "Error: '$GODOT_BIN binary executable not found."
  echo "Please ensure '$GODOT_BIN' is in your PATH."
  echo "Your path is:\n$PATH"
  exit 1
fi

if [ "$#" -ge 1 ] && [ "$1" = "--force" ]; then
  FORCE_BUILD=true
else
  FORCE_BUILD=false
fi

# Derive export name
PROJECT_NAME=$(grep '^config/name=' project.godot | sed -E 's/config\/name="([^"]+)"/\1/')
GAME_VERSION=$(grep '^config/version=' project.godot | sed -E 's/config\/version="([^"]+)"/\1/')
GODOT_VERSION=$($GODOT_BIN --version)
if [ -z "$PROJECT_NAME" ] || [ -z "$GAME_VERSION" ]; then
  echo "Error: Could not extract config/name or config/version from project.godot"
  exit 1
fi
EXPORT_NAME="${PROJECT_NAME}-${GAME_VERSION}-[godot.$GODOT_VERSION]"

# Check for uncommitted changes or untracked files in the Git workspace
if [ "$FORCE_BUILD" != "true" ] && [ -n "$(git status --porcelain)" ]; then
  echo "Error: There are uncommitted changes or untracked files in the Git workspace."
  echo "Please commit/stash them before building. Or run the script with --force flag."
  exit 1
fi

# Export the game and redirect Godot output to a file
export_game() {
  local export_preset="$1"
  local output_dir="$2"
  local build_name="$3"
  local logfile="$output_dir/build.log"
  
  # Get the current date and time
  current_datetime=$(date "+%Y-%m-%d %H:%M:%S")
  
  # Get the current Git commit hash (if available)
  git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "No Git commit available")
  
  # Create a log entry with date, time, and Git commit
  log_entry="$current_datetime - $PROJECT_NAME - Git commit: $git_commit"
  
  echo "Building $export_preset..."

  # Append the log entry to the build log file
  mkdir -p "$output_dir"
  touch $logfile
  echo "$log_entry" > "$logfile"
  
  $GODOT_BIN --headless --export-release "$export_preset" "$output_dir/$build_name" >> $logfile 2>&1
  
  echo "Done.\n"
}

export_game "Linux/X11" "builds/$EXPORT_NAME/linux" "$EXPORT_NAME.x86_64"
export_game "Windows Desktop" "builds/$EXPORT_NAME/windows" "$EXPORT_NAME.exe"
export_game "macOS" "builds/$EXPORT_NAME/osx" "$EXPORT_NAME.dmg"