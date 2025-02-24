# This podspec is made with reference to:
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
  spec.name        = "example-node-api-module"
  spec.version     = package['version']
  spec.summary     = package['description']
  spec.homepage    = package['homepage']
  spec.license     = package['license']
  spec.authors     = package['author']
  spec.source      = ENV['addon-artifact-url'] ?
    { http: ENV['addon-artifact-url'] } :
    { git: "https://github.com/shirakaba/react-native-node-api-module-autolinking.git", tag: "v#{spec.version}" }
  spec.platforms   = { :osx => "10.13", :ios => "12.0", :visionos => "1.0", :tvos => "12.0" }

  # TODO: As this library is only to be used on the JS side, I'm not sure we
  #       have any use to expose headers. Except, perhaps, if we need to expose
  #       a custom C function to register the module
  # spec.preserve_paths      = ["destroot/bin/*"].concat(AddonHelper::BUILD_TYPE == :debug ? ["**/*.{h,c,cpp}"] : [])
  # spec.source_files        = "destroot/include/**/*.h"
  # spec.header_mappings_dir = "destroot/include"

  spec.ios.vendored_frameworks = "build/universal/addon.xcframework"
  spec.visionos.vendored_frameworks = "build/universal/addon.xcframework"
  spec.tvos.vendored_frameworks = "build/universal/addon.xcframework"
  spec.osx.vendored_frameworks = "build/universal/addon.xcframework"

  unless ENV['addon-artifact-url']
    spec.prepare_command = <<-EOS
      # When true, debug build will be used.
      # See `build-apple-framework.sh` for details
      DEBUG=#{AddonHelper::BUILD_TYPE == :debug}

      ./scripts/build-all-apple-frameworks.sh
    EOS
  end
end