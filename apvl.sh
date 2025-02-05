#!/bin/bash
# APVL(Automatic Python Version Linker) is a simple script that automatically links different versions of python.
# Copyright (C) 2025 Hyogeun Park (hyotaime [at] hyotaime.com)
# Last revised February 5, 2025
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

set -e -u # Exit immediately on command failure, prevent use of undefined variables

# Function to print an error message and exit immediately
error_exit() {
  echo "❌ ERROR: $1" >&2
  exit 1
}

if [ -z "$1" ]; then
  error_exit "No argument provided for python version. Usage: ./apvl.sh {python_version}"
fi

VERSION=$1

VERSION_REGEX='^[0-9]+\.[0-9]+$'
if [[ ! "$VERSION" =~ $VERSION_REGEX ]]; then
  error_exit "Invalid version format. Expected format: X.Y (e.g., 3.11)"
fi

CELLAR_PYTHON_BASE="/opt/homebrew/Cellar/python@$VERSION"
if [ ! -d "$CELLAR_PYTHON_BASE" ]; then
  error_exit "Python $VERSION doesn't exist in Homebrew."
fi

CELLAR_PYTHON_DIR=$(find "$CELLAR_PYTHON_BASE" -maxdepth 1 -type d -name "$VERSION.*" | sort -V | tail -n 1)
if [ -z "$CELLAR_PYTHON_DIR" ]; then
  error_exit "Could not find the full version directory inside $CELLAR_PYTHON_BASE."
fi

CELLAR_PYTHON_BIN="$CELLAR_PYTHON_DIR/bin/python$VERSION"
CELLAR_PYTHON3_BIN="$CELLAR_PYTHON_DIR/bin/python3"
CELLAR_PYTHON_CONFIG="$CELLAR_PYTHON_DIR/bin/python$VERSION-config"
CELLAR_PYTHON3_CONFIG="$CELLAR_PYTHON_DIR/bin/python3-config"
CELLAR_IDLE="$CELLAR_PYTHON_DIR/bin/idle$VERSION"
CELLAR_IDLE3="$CELLAR_PYTHON_DIR/bin/idle3"
CELLAR_PIP="$CELLAR_PYTHON_DIR/bin/pip$VERSION"
CELLAR_PIP3="$CELLAR_PYTHON_DIR/bin/pip3"
CELLAR_PYDOC="$CELLAR_PYTHON_DIR/bin/pydoc$VERSION"
CELLAR_PYDOC3="$CELLAR_PYTHON_DIR/bin/pydoc3"
CELLAR_WHEEL="$CELLAR_PYTHON_DIR/bin/wheel$VERSION"
CELLAR_WHEEL3="$CELLAR_PYTHON_DIR/bin/wheel3"

if [ ! -f "$CELLAR_PYTHON_BIN" ]; then
  error_exit "Python binary not found at $CELLAR_PYTHON_BIN"
fi

# Define symbolic link paths
HB_PYTHON_BIN="/opt/homebrew/bin/python$VERSION"
HB_PYTHON_CONFIG="/opt/homebrew/bin/python$VERSION-config"
HB_PYTHON3_BIN="/opt/homebrew/bin/python3"
HB_PYTHON3_CONFIG="/opt/homebrew/bin/python3-config"
HB_IDLE="/opt/homebrew/bin/idle$VERSION"
HB_IDLE3="/opt/homebrew/bin/idle3"
HB_PIP="/opt/homebrew/bin/pip$VERSION"
HB_PIP3="/opt/homebrew/bin/pip3"
HB_PYDOC="/opt/homebrew/bin/pydoc$VERSION"
HB_PYDOC3="/opt/homebrew/bin/pydoc3"
HB_WHEEL="/opt/homebrew/bin/wheel$VERSION"
HB_WHEEL3="/opt/homebrew/bin/wheel3"

LOCAL_PYTHON_BIN="/opt/local/bin/python$VERSION"
LOCAL_PYTHON_CONFIG="/opt/local/bin/python$VERSION-config"
LOCAL_PYTHON3_BIN="/opt/local/bin/python3"
LOCAL_PYTHON3_CONFIG="/opt/local/bin/python3-config"
LOCAL_PYDOC="/opt/local/bin/pydoc$VERSION"
LOCAL_PYDOC3="/opt/local/bin/pydoc3"

# ✅ Function to create symbolic links
create_symlink() {
  local TARGET="$1"
  local SOURCE="$2"

  if [ -L "$TARGET" ]; then
    CURRENT_LINK=$(readlink "$TARGET")
    if [ "$CURRENT_LINK" == "$SOURCE" ]; then
      echo "✔ $TARGET -> $SOURCE is already exist correctly"
      return 0
    else
      echo "🔄 Updating existing symbolic link: $TARGET -> $SOURCE"
    fi
  else
    echo "➕ Creating new symbolic link $TARGET -> $SOURCE"
  fi

  sudo ln -s -f "$SOURCE" "$TARGET" || error_exit "Failed to create symlink: $TARGET -> $SOURCE"
  echo "✅ Successfully linked $TARGET -> $SOURCE"
}

# ✅ Create symbolic links for Homebrew
echo "Processing at Homebrew..."
# Can't use realpath --relative-to on macOS
# CELLAR_PYTHON_BIN_REL=$(realpath --relative-to="$(dirname "$HB_PYTHON_BIN")" "$CELLAR_PYTHON_BIN")
# CELLAR_PYTHON_CONFIG_REL=$(realpath --relative-to="$(dirname "$HB_PYTHON_CONFIG")" "$CELLAR_PYTHON_CONFIG")
# create_symlink "$HB_PYTHON_BIN" "$CELLAR_PYTHON_BIN_REL" "Homebrew"
# create_symlink "$HB_PYTHON_CONFIG" "$CELLAR_PYTHON_CONFIG_REL" "Homebrew"
# create_symlink "$HB_PYTHON3_BIN" "$CELLAR_PYTHON_BIN_REL" "Homebrew"
# create_symlink "$HB_PYTHON3_CONFIG" "$CELLAR_PYTHON_CONFIG_REL" "Homebrew"

CELLAR_PYTHON_BIN_REL=$(echo "$CELLAR_PYTHON_BIN" | sed 's|^/opt/homebrew/||')
CELLAR_PYTHON3_BIN_REL=$(echo "$CELLAR_PYTHON3_BIN" | sed 's|^/opt/homebrew/||')
CELLAR_PYTHON_CONFIG_REL=$(echo "$CELLAR_PYTHON_CONFIG" | sed 's|^/opt/homebrew/||')
CELLAR_PYTHON3_CONFIG_REL=$(echo "$CELLAR_PYTHON3_CONFIG" | sed 's|^/opt/homebrew/||')
CELLAR_IDLE_REL=$(echo "$CELLAR_IDLE" | sed 's|^/opt/homebrew/||')
CELLAR_IDLE3_REL=$(echo "$CELLAR_IDLE3" | sed 's|^/opt/homebrew/||')
CELLAR_PIP_REL=$(echo "$CELLAR_PIP" | sed 's|^/opt/homebrew/||')
CELLAR_PIP3_REL=$(echo "$CELLAR_PIP3" | sed 's|^/opt/homebrew/||')
CELLAR_PYDOC_REL=$(echo "$CELLAR_PYDOC" | sed 's|^/opt/homebrew/||')
CELLAR_PYDOC3_REL=$(echo "$CELLAR_PYDOC3" | sed 's|^/opt/homebrew/||')
CELLAR_WHEEL_REL=$(echo "$CELLAR_WHEEL" | sed 's|^/opt/homebrew/||')
CELLAR_WHEEL3_REL=$(echo "$CELLAR_WHEEL3" | sed 's|^/opt/homebrew/||')

cd /opt/homebrew/bin || error_exit "Failed to change directory to /opt/homebrew/bin"
# python
create_symlink "$HB_PYTHON_BIN" "../$CELLAR_PYTHON_BIN_REL"
create_symlink "$HB_PYTHON_CONFIG" "../$CELLAR_PYTHON_CONFIG_REL"
create_symlink "$HB_PYTHON3_BIN" "../$CELLAR_PYTHON3_BIN_REL"
create_symlink "$HB_PYTHON3_CONFIG" "../$CELLAR_PYTHON3_CONFIG_REL"
# idle
create_symlink "$HB_IDLE" "../$CELLAR_IDLE_REL"
create_symlink "$HB_IDLE3" "../$CELLAR_IDLE3_REL"
# pip
create_symlink "$HB_PIP" "../$CELLAR_PIP_REL"
create_symlink "$HB_PIP3" "../$CELLAR_PIP3_REL"
# pydoc
create_symlink "$HB_PYDOC" "../$CELLAR_PYDOC_REL"
create_symlink "$HB_PYDOC3" "../$CELLAR_PYDOC3_REL"
# wheel
create_symlink "$HB_WHEEL" "../$CELLAR_WHEEL_REL"
create_symlink "$HB_WHEEL3" "../$CELLAR_WHEEL3_REL"

cd - >/dev/null || error_exit "Failed to return to the previous directory"

# ✅ Create symbolic links for Local
echo "Processing at Local..."
create_symlink "$LOCAL_PYTHON_BIN" "$HB_PYTHON_BIN"
create_symlink "$LOCAL_PYTHON_CONFIG" "$HB_PYTHON_CONFIG"
create_symlink "$LOCAL_PYTHON3_BIN" "$HB_PYTHON3_BIN"
create_symlink "$LOCAL_PYTHON3_CONFIG" "$HB_PYTHON3_CONFIG"
create_symlink "$LOCAL_PYDOC" "$HB_PYDOC"
create_symlink "$LOCAL_PYDOC3" "$HB_PYDOC3"

echo "🎉 Python $VERSION linking completed!"
