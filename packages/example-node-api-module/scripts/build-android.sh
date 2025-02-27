#!/bin/bash

set -e  # Exit on error

if [ "$DEBUG" = true ]; then
  BUILD_TYPE="Debug"
else
  BUILD_TYPE="Release"
fi

if ! command -v ninja &> /dev/null; then
    echo "Ninja is required. Install it with: \`brew install ninja\` (macOS) or \`apt install ninja\` (Linux)."
    exit 1
fi

# Detect CMake
if ! command -v cmake &> /dev/null; then
    echo "CMake is required. Install it with: \`brew install cmake\` (macOS) or \`apt install cmake\` (Linux)."
    exit 1
fi

function get_cmake_js_path {
    node --print -e "const path = require('path'); path.resolve(path.dirname(require.resolve('cmake-js/package.json')), require('cmake-js/package.json').bin['cmake-js'])"
}

function build_android_arch {
  local cmake_js=$1
  local ABI=$2

  echo "Building for Android ABI: '$ABI'"

  "$cmake_js" compile --out="build/android-$ABI" \
    --CDCMAKE_BUILD_TYPE=$BUILD_TYPE \
    --CDANDROID_ABI="$ABI" \
    --CDANDROID_PLATFORM=android-21 \
    --CDCMAKE_SYSTEM_NAME=Android \
    --CDCMAKE_SYSTEM_VERSION=21 \
    --CDCMAKE_ANDROID_ARCH_ABI="$ABI" \
    --CDADDON_TARGET_PLATFORM="android" \
    --CDCMAKE_TOOLCHAIN_FILE="$ANDROID_HOME/ndk/27.1.12297006/build/cmake/android.toolchain.cmake" \
    --CDCMAKE_MAKE_PROGRAM=ninja \
    --CDG=Ninja
}

function build_all_android_archs {
  cmake_js=$(get_cmake_js_path)

  for arch in $@; do
    build_android_arch "$cmake_js" "$arch"
  done
}

build_all_android_archs "armeabi-v7a" "arm64-v8a" "x86" "x86_64"

echo "✅ Android build completed successfully."
