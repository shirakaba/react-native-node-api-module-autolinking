#!/bin/bash
#
# This source code is made with reference to:
# https://github.com/facebook/hermes/blob/main/utils/build-ios-framework.sh
#
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

. ./scripts/build-apple-framework.sh

if [ ! -d build/universal/Release/addon.xcframework ]; then
    ios_deployment_target=$(get_ios_deployment_target)
    visionos_deployment_target=$(get_visionos_deployment_target)
    tvos_deployment_target=$(get_tvos_deployment_target)
    mac_deployment_target=$(get_mac_deployment_target)
    cmake_js=$(get_cmake_js_path)
    release_version=$(get_release_version)

    # SYSTEM_NAME values (e.g. "Darwin") are with reference to:
    # https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html
    # https://gitlab.kitware.com/cmake/cmake/-/blob/2785364b7ba32de1f718e9e5fd049a039414a669/Tests/RunCMake/XcFramework/RunCMakeTest.cmake#L18

    build_apple_framework "iphoneos" "arm64" "$ios_deployment_target" "$cmake_js" "$release_version" "iOS"
    build_apple_framework "iphonesimulator" "x86_64;arm64" "$ios_deployment_target" "$cmake_js" "$release_version" "iOS"
    build_apple_framework "catalyst" "x86_64;arm64" "$ios_deployment_target" "$cmake_js" "$release_version" "iOS"
    build_apple_framework "xros" "arm64" "$visionos_deployment_target" "$cmake_js" "$release_version" "visionOS"
    build_apple_framework "xrsimulator" "arm64" "$visionos_deployment_target" "$cmake_js" "$release_version" "visionOS"
    build_apple_framework "appletvos" "arm64" "$tvos_deployment_target" "$cmake_js" "$release_version" "tvOS"
    build_apple_framework "appletvsimulator" "x86_64;arm64" "$tvos_deployment_target" "$cmake_js" "$release_version" "tvOS"
    build_apple_framework "macosx" "x86_64;arm64" "$mac_deployment_target" "$cmake_js" "$release_version" "Darwin"

    create_universal_framework "iphoneos" "iphonesimulator" "catalyst" "xros" "xrsimulator" "appletvos" "appletvsimulator" "macosx"
else
    echo "Skipping; Clean \"build\" to rebuild".
fi