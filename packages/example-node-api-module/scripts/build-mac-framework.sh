#!/bin/bash
#
# This source code is made with reference to:
# https://github.com/facebook/hermes/blob/main/utils/build-mac-framework.sh
#
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

. ./scripts/build-apple-framework.sh
if [ ! -d build/macosx/Release/addon.framework ]; then
    mac_deployment_target=$(get_mac_deployment_target)
    cmake_js=$(get_cmake_js_path)
    release_version=$(get_release_version)

    build_apple_framework "macosx" "x86_64;arm64" "$mac_deployment_target" "$cmake_js" "$release_version"
else
    echo "Skipping; Clean \"build\" to rebuild".
fi
