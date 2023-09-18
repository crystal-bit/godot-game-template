#!/bin/sh

GODOT_BIN="godot"
BIN_NAME="game-name"

# Check if the command is available
if ! command -v "$GODOT_BIN" &> /dev/null; then
  echo "Error: $GODOT_BIN is not available."
  exit 1
fi

# Check for uncommitted changes or untracked files in the Git workspace
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: There are uncommitted changes or untracked files in the Git workspace. Please commit or stash them before building."
  exit 1
fi

# Export the game and redirect Godot output to a file
run_godot() {
  local export_preset="$1"
  local output_dir="$2"
  local build_name="$3"
  local logfile="$output_dir/build.log"
  
  # Get the current date and time
  current_datetime=$(date "+%Y-%m-%d %H:%M:%S")
  
  # Get the current Git commit hash (if available)
  git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "No Git commit available")
  
  # Create a log entry with date, time, and Git commit
  log_entry="$current_datetime - Git commit: $git_commit"
  
  echo "Building $export_preset"

  # Append the log entry to the build log file
  echo "$log_entry" > "$logfile"
  
  mkdir -p "$output_dir"
  
  $GODOT_BIN --headless --export-release "$export_preset" "$output_dir/$build_name" >> $logfile 2>&1
  
  echo "$export_preset built."
  echo
}

run_godot "Linux/X11" "builds/linux" "$BIN_NAME.x86_64"
run_godot "macOS" "builds/osx" "$BIN_NAME.dmg"
run_godot "Windows Desktop" "builds/windows" "$BIN_NAME.exe"
run_godot "Web" "builds/html5" "index.html"
