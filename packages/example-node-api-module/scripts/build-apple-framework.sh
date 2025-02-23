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
  node --print -e "require('./package.json').version"
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

function get_catalyst_deployment_target {
    local user_target="$1"
    local min_target="$2"

    # Compare versions using sort -V (which understands version numbers)
    if [[ "$(printf "%s\n%s" "$user_target" "$min_target" | sort -V | head -n1)" == "$user_target" ]]; then
        echo "$min_target"
    else
        echo "$user_target"
    fi
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

  if [[ $1 == catalyst ]]; then
    sysroot="macosx"
    supports_maccatalyst="YES"

    # For Catalyst, CMAKE_OSX_DEPLOYMENT_TARGET determines the <VERSION_MIN> in
    # `--target=<ARCH>-apple-ios<VERSION_MIN>-macabi`, which refers to which
    # version of the iOS SDK the macOS app should target.
    # https://gitlab.kitware.com/cmake/cmake/-/blob/2785364b7ba32de1f718e9e5fd049a039414a669/Modules/Platform/Apple-Clang.cmake
    #
    # 14.0 is the minimum iOS version that supports both x86 and arm64, so we
    # restrict the minimum target to whatever is the lower of the user's iOS.
    # https://doc.rust-lang.org/nightly/rustc/platform-support/apple-ios-macabi.html#os-version
    local min_target="14.0"
    osx_deployment_target=$(get_catalyst_deployment_target $3 $min_target)
  else
    sysroot="$1"
    supports_maccatalyst="NO"
    osx_deployment_target="$3"
  fi

  "$4" compile --out="build/$1" \
    --CDCMAKE_OSX_SYSROOT=$sysroot \
    --CDADDON_TARGET_PLATFORM="$1" \
    --CDCMAKE_OSX_ARCHITECTURES:STRING="$2" \
    --CDCMAKE_OSX_DEPLOYMENT_TARGET:STRING="$osx_deployment_target" \
    --CDRELEASE_VERSION="$5" \
    --CDCMAKE_XCODE_ATTRIBUTE_SUPPORTS_MACCATALYST="$supports_maccatalyst" \
    --CDCMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE:BOOLEAN="$enable_bitcode" \
    --CDCMAKE_BUILD_TYPE="$BUILD_TYPE"
}

# Utility function to build an Apple framework
function build_apple_framework {
  echo "Building framework for $1 with architectures: $2"

  configure_apple_framework "$1" "$2" "$3" "$4" "$5"

  # if [[ "$BUILD_SYSTEM" == "Ninja" ]]; then
  #   (cd "./build_$1" && ninja install/strip)
  # else
  #   (cd "./build_$1" && make install/strip)
  # fi
}

# Accepts an array of frameworks and will place all of the architectures into a
# universal folder and then remove the merged frameworks from the build folder
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