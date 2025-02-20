# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE-hermes.txt file in the root directory of this source tree.

cd "$(dirname "$0")" || exit 1

# Accepts an array of frameworks and will place all of
# the architectures into an universal folder and then remove
# the merged frameworks from destroot
function create_universal_framework {
  cd ../build || exit 1

  local platforms=("$@")
  local args=""

  echo "Creating universal framework for platforms: ${platforms[*]}"

  for i in "${!platforms[@]}"; do
    args+="-framework ${platforms[$i]}/addon.framework "
  done

  mkdir universal
  xcodebuild -create-xcframework $args -output "universal/addon.xcframework"

  for platform in $@; do
    rm -r "$platform"
  done

  cd - || exit 1
}
