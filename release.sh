#!/bin/sh

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [--force] <EXPORT_NAME> [<GODOT_BIN>]"
  exit 1
fi

FORCE_BUILD=false

# Check for the --force parameter
if [ "$1" == "--force" ]; then
  FORCE_BUILD=true
  shift
fi

EXPORT_NAME="$1"
GODOT_BIN="${2:-godot}"

# Check if the command is available
if ! command -v "$GODOT_BIN" &> /dev/null; then
  echo "Error: Godot binary not found at '$GODOT_BIN'"
  exit 1
fi

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
  log_entry="$current_datetime - Git commit: $git_commit"
  
  echo "Building $export_preset..."

  # Append the log entry to the build log file
  mkdir -p "$output_dir"
  touch $logfile
  echo "$log_entry" > "$logfile"
  
  $GODOT_BIN --headless --export-release "$export_preset" "$output_dir/$build_name" >> $logfile 2>&1
  
  echo "$export_preset built."
  echo
}

export_game "Linux/X11" "builds/$EXPORT_NAME/linux" "$EXPORT_NAME.x86_64"
export_game "macOS" "builds/$EXPORT_NAME/osx" "$EXPORT_NAME.dmg"
export_game "Windows Desktop" "builds/$EXPORT_NAME/windows" "$EXPORT_NAME.exe"
export_game "Web" "builds/$EXPORT_NAME/html5" "index.html"
