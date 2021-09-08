#!/usr/bin/env bash
set -euo pipefail

# Cura maintains a config directory under ~/Library/Application\
# Support/cura/{version} where {version} is the major.minor version of the
# Cura program itself.
#
# This script ensures the symlink points to the latest version.

curaDir="$HOME/Library/Application\\ Support/cura"

function usage {
  echo "Usage: $0 <new-version>" 1>&2
}

version=$1

if [[ "$version" == "" ]]; then
  usage
  exit 1
fi

# TODO: Download latest version as a .dmg, and install it.


# mv is not adequate for moving individual directories in a mass means, so
# find each directory and move it independently.
ls -d */ \
  | sed -E 's@(.*)/$@\1@' \
  | xargs -I{} "rm -rf {}; mv $curaDir/$version/{} ./{}" \;


# Also move the individual files. There will be warnings.
mv $curaDir/$version/* .
