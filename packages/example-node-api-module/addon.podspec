# This source code is made with reference to:
# https://github.com/facebook/hermes/blob/main/hermes-engine.podspec
#
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE-hermes.txt file in the root directory of this source tree.

module AddonHelper
  # BUILD_TYPE = :debug
  BUILD_TYPE = :release
end

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |spec|
  spec.name        = "hermes-engine"
  spec.version     = package['version']
  spec.summary     = package['description']
  spec.homepage    = "https://github.com/shirakaba/react-native-node-api-module-autolinking"
  spec.license     = { type: "MIT", file: "LICENSE" }
  spec.author      = "Jamie Birch"
  spec.source      = ENV['addon-artifact-url'] ? { http: ENV['addon-artifact-url'] } : { git: "https://github.com/shirakaba/react-native-node-api-module-autolinking.git", tag: "v#{spec.version}" }
  spec.platforms   = { :osx => "10.13", :ios => "12.0", :visionos => "1.0", :tvos => "12.0" }

  # TODO: map these to our build

  # spec.preserve_paths      = ["destroot/bin/*"].concat(AddonHelper::BUILD_TYPE == :debug ? ["**/*.{h,c,cpp}"] : [])
  # spec.source_files        = "destroot/include/**/*.h"
  # spec.header_mappings_dir = "destroot/include"

  # spec.ios.vendored_frameworks = "destroot/Library/Frameworks/universal/hermes.xcframework"
  # spec.visionos.vendored_frameworks = "destroot/Library/Frameworks/universal/hermes.xcframework"
  # spec.tvos.vendored_frameworks = "destroot/Library/Frameworks/universal/hermes.xcframework"
  # spec.osx.vendored_frameworks = "destroot/Library/Frameworks/macosx/hermes.framework"

  spec.xcconfig = {
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++17",
    "CLANG_CXX_LIBRARY" => "compiler-default",
    "GCC_PREPROCESSOR_DEFINITIONS" => "HERMES_ENABLE_DEBUGGER=1"
  }

  unless ENV['hermes-artifact-url']
    spec.prepare_command = <<-EOS
      # When true, debug build will be used.
      # See `build-apple-framework.sh` for details
      DEBUG=#{AddonHelper::BUILD_TYPE == :debug}

      # Build iOS framework
      ./scripts/build-ios-framework.sh

      # Build Mac framework
      ./scripts/build-mac-framework.sh
    EOS
  end
end