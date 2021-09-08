#!/usr/bin/env bash
set -euo pipefail

# Cura maintains a config directory under ~/Library/Application\
# Support/cura/{version} where {version} is the major.minor version of the
# Cura program itself.
#
# This script ensures the symlink points to the latest version.
# TODO: Download latest version as a .dmg, and install it.
# TODO: Watch out for other dot directories. Ideally these scripts should be
# their own repo, and the cura settings themselves a separate repo. We really
# don't want to crush our git dir, or hide other hidden dirs, or conflict with
# a .gitignore if they ever add one.

function usage {
  echo "Usage: $0 <new-version>" 1>&2
}

# Export these so our subshell we use later can use them.
export dir="$( cd -- "$(dirname ".")" >/dev/null 2>&1 ; pwd -P )"
export curaDir="$HOME/Library/Application Support/cura"
export curaVersion="${1:-}"


if [[ "$curaVersion" == "" ]]; then
  usage
  exit 1
fi


# mv is not adequate for moving individual directories in a mass means, so
# find each directory and move it independently.
# Since we can't inline comment multi-line commands in bash, we keep a parallel
# here:
# 1. Just find, nothing special. ls -d doesn't work well for this.
# 2. Give us just the directory name, sans slashes. We don't want the absolute
# path. We need a relative path because we're basically switching the absolute
# path. The current directory itself won't have a slash, but subdirectories will
# have a prefixed slash so we want that removed while still blanking the current
# directory (see step 4).
# 3. Strip out dot directories - specifically the .git dir.
# 4. Strip empty entries - specifically this should be the current dir, but
# mangled from all of our massaging. We shouldn't be operating on blank dirs
# anyways.
# 5. Print the results, because that's handy.
# 6. Remove the destination dir, or the mv will fail.
# 7. Do the actual move! Shew.
echo "Moving directories from '$curaDir/$curaVersion' to cura-settings..." 1>&2
find "$curaDir/$curaVersion" -type d  -maxdepth 1 \
  | sed -E "s@$curaDir/$curaVersion(/?)@@" \
  | grep -v -E '^\.' \
  | grep -v -E '^$' \
  | xargs -I{} bash -c 'echo "Moving {}..." 1>&2; \
  rm -rf "{}"; \
  mv "$curaDir/$curaVersion/{}" "{}"'
echo "Moving of directories successful." 1>&2

# Also move the individual files. There will be warnings.
mv "$curaDir/$curaVersion/"* .
echo "Removing original dir at '$curaDir/$curaVersion'..." 1>&2
rm -rf "$curaDir/$curaVersion"
ln -snf "$dir" "$curaDir/$curaVersion"
