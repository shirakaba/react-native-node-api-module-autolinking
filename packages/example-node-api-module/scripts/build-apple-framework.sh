#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

if [ "$DEBUG" = true ]; then
  BUILD_TYPE="Debug"
else
  BUILD_TYPE="Release"
fi

function command_exists {
  command -v "${1}" > /dev/null 2>&1
}

if command_exists "cmake"; then
  if command_exists "ninja"; then
    BUILD_SYSTEM="Ninja"
  else
    BUILD_SYSTEM="Unix Makefiles"
  fi
else
  echo >&2 'CMake is required to install Hermes, install it with: brew install cmake'
  exit 1
fi

function get_release_version {
  ruby -rcocoapods-core -rjson -e "puts Pod::Specification.from_file('addon.podspec').version"
}

function get_ios_deployment_target {
  ruby -rcocoapods-core -rjson -e "puts Pod::Specification.from_file('addon.podspec').deployment_target('ios')"
}

function get_visionos_deployment_target {
  ruby -rcocoapods-core -rjson -e "puts Pod::Specification.from_file('addon.podspec').deployment_target('visionos')"
}

function get_tvos_deployment_target {
  ruby -rcocoapods-core -rjson -e "puts Pod::Specification.from_file('addon.podspec').deployment_target('tvos')"
}

function get_mac_deployment_target {
  ruby -rcocoapods-core -rjson -e "puts Pod::Specification.from_file('addon.podspec').deployment_target('osx')"
}

# We could simply use `npx cmake-js` each time, but manually resolving the path
# to the binary up front should shave off a little time on each call.
function get_cmake_js_path {
  node --print -e "const path = require('path'); path.resolve(path.dirname(require.resolve('cmake-js/package.json')), require('cmake-js/package.json').bin['cmake-js'])"
}

# Utility function to configure an Apple framework
function configure_apple_framework {
  local build_cli_tools enable_bitcode

  if [[ $1 == appletvos || $1 == iphoneos || $1 == catalyst || $1 == xros ]]; then
    enable_bitcode="YES"
  else
    enable_bitcode="NO"
  fi

  "$4" compile --out="build/$1" \
    --CDCMAKE_OSX_SYSROOT=$1 \
    --CDCMAKE_OSX_ARCHITECTURES:STRING="$2" \
    --CDCMAKE_OSX_DEPLOYMENT_TARGET:STRING="$3" \
    --CDCMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE:BOOLEAN="$enable_bitcode" \
    --CDADDON_BUILD_APPLE_FRAMEWORK:BOOLEAN=true \
    --CDCMAKE_BUILD_TYPE="$BUILD_TYPE"
}

# Utility function to build an Apple framework
function build_apple_framework {
  echo "Building framework for $1 with architectures: $2"

  configure_apple_framework "$1" "$2" "$3" "$4"

  # if [[ "$BUILD_SYSTEM" == "Ninja" ]]; then
  #   (cd "./build_$1" && ninja install/strip)
  # else
  #   (cd "./build_$1" && make install/strip)
  # fi
}

# Accepts an array of frameworks and will place all of
# the architectures into an universal folder and then remove
# the merged frameworks from destroot
function create_universal_framework {
  cd ./build || exit 1

  local platforms=("$@")
  local args=""

  echo "Creating universal framework for platforms: ${platforms[*]}"

  for i in "${!platforms[@]}"; do
    args+="-framework ${platforms[$i]}/Release/addon.framework "
  done

  mkdir universal
  xcodebuild -create-xcframework $args -output "universal/addon.xcframework"

  # for platform in $@; do
  #   rm -r "$platform"
  # done

  cd - || exit 1
}