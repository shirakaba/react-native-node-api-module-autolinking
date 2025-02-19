{
  'targets': [
    {
      'target_name': 'addon',
      'sources': ['addon.c'],
      'cflags!': ['-fno-exceptions'],
      'cflags_cc!': ['-fno-exceptions'],
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
        [
          'OS=="mac"',
          {
            'xcode_settings': {
              'OTHER_CFLAGS': ['-arch x86_64', '-arch arm64'],
              'OTHER_LDFLAGS': ['-arch x86_64', '-arch arm64'],
              'SDKROOT': 'macosx',
              'MACOSX_DEPLOYMENT_TARGET': '10.13',
            },
          },
        ],
        ["OS=='ios'", {'xcode_settings': {'SDKROOT': 'iphoneos'}}],
        ["OS=='android'", {'cflags': ['-DANDROID']}],
      ],
    },
  ],
}
