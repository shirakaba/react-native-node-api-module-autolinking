{
  # As we can't pass in args or env vars, perhaps the only way to vary the build
  # to specify a BUILD_TARGET might be to get a shell script to store state on
  # the file system or something. Ridiculous.
  # https://github.com/superunrelated/node-gd/blob/89704d9b01998827ebfcb7a5cbe41399399a578d/binding.gyp#L5
  'variables': {},
  'targets': [
    {
      'target_name': 'addon',
      'sources': ['addon.c'],
      'cflags!': ['-fno-exceptions'],
      'cflags_cc!': ['-fno-exceptions'],
      # If two sets of conditions match, then the one later in this array will
      # merge all its properties into whatever properties have been built up by
      # previous matching conditions.
      'conditions': [
        # Here, we build a universal binary:
        # https://github.com/node-usb/node-usb/blob/8e81f8c8eb1536a37544647cab659dea09a539ed/binding.gyp#L60
        #
        # However, we could perhaps build individual binaries like this:
        # https://github.com/andresavic/grandiose/blob/0fe6266b1513818fc198132994a291dc6e4fb40f/binding.gyp#L70
        #
        # Wondering how to support iOS, though. References:
        # https://github.com/NativeScript/runtime-node-api/blob/29151c404044ddb1f9270c64b1bbcc249db6352d/runtime/CMakeLists.txt#L20
        # https://github.com/mceSystems/node-native-script/blob/b76417612a13f9435610fd68d7060ee8f520b315/binding.gyp#L8
        #
        # Multi-arch CI flow:
        # https://github.com/node-hid/node-hid/blob/078d2e2ee9863cc596a40d0830f430de89afddba/.github/workflows/build.yml#L98C11-L98C26
        [
          'OS=="mac"',
          {
            'xcode_settings': {
              'SDKROOT': 'macosx',
              'MACOSX_DEPLOYMENT_TARGET': '10.13',
            },
          },
        ],
        [
          "OS == 'mac' and target_arch == 'x86_64'",
          {
            'xcode_settings': {
              'OTHER_CFLAGS': ['-arch x86_64'],
              'OTHER_LDFLAGS': ['-arch x86_64'],
            },
          },
        ],
        [
          "OS == 'mac' and target_arch == 'arm64'",
          {
            'xcode_settings': {
              'OTHER_CFLAGS': ['-arch arm64'],
              'OTHER_LDFLAGS': ['-arch arm64'],
            },
          },
        ],
      ],
    },
  ],
}
