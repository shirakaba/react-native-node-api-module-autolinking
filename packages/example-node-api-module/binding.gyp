{
  'targets': [
    {
      'target_name': 'addon',
      'sources': ['addon.c'],
      'cflags!': ['-fno-exceptions'],
      'cflags_cc!': ['-fno-exceptions'],
      'conditions': [
        [
          "OS=='mac'",
          {
            'xcode_settings': {
              'MACOSX_DEPLOYMENT_TARGET': '10.13',
              'GCC_SYMBOLS_PRIVATE_EXTERN': 'YES',
            },
          },
        ],
        ["OS=='ios'", {'xcode_settings': {'SDKROOT': 'iphoneos'}}],
        ["OS=='android'", {'cflags': ['-DANDROID']}],
      ],
    },
  ],
}
