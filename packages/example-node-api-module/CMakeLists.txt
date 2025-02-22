include(CMakePrintHelpers)

cmake_print_variables(ADDON_TARGET_PLATFORM CMAKE_XCODE_ATTRIBUTE_SUPPORTS_MACCATALYST)

# v3.28 is the minimum that supports xros and xrsimulator.
cmake_minimum_required(VERSION 3.28)
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0042 NEW)

# TODO: investigate how `xcodebuild archive` works
# https://github.com/NativeScript/ios/blob/d4f3b680ba77823d9e03b82548ead26706993b99/build_nativescript.sh#L64
# Maybe we should get cmake to generate an xcodeproj and call xcodebuild from it?
# Also see: https://gitlab.kitware.com/cmake/cmake/-/issues/20132#note_673870
if(ADDON_TARGET_PLATFORM MATCHES "catalyst")
  # The PR that added Catalyst support to cmake:
  # https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9595

  # This hybrid of iOS and macosx unlocks all cmake's Catalyst support.
  set(CMAKE_SYSTEM_NAME "iOS")
  set(CMAKE_OSX_SYSROOT "macosx")

  # While this usually fills in the version number in
  # '-mmacosx-version-min=14.0', when you set CMAKE_SYSTEM_NAME to 'iOS', it
  # instead fills in '--target=<ARCH>-apple-ios<VERSION_MIN>-macabi'.
  # TODO: take this from the shell script
  set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")

  # Not sure which of these are real flags and whether any even contribute.
  set(CMAKE_XCODE_ATTRIBUTE_MACCATALYST_DEPLOYMENT_TARGET "13.0")
  set(CMAKE_XCODE_ATTRIBUTE_MACCATALYST_SUPPORTED_PLATFORMS "macosx")
  set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2")
  set(CMAKE_XCODE_GENERATE_SCHEME ON)

  # https://gitlab.kitware.com/cmake/cmake/-/issues/20132#note_897847
  # https://gitlab.kitware.com/cmake/cmake/-/issues/24650
  # cc: warning: overriding '-mmacosx-version-min=12.0' option with '-target x86_64-arm64-apple-ios13.0-macabi' [-Woverriding-t-option]
  # cc: error: invalid version number in '-target x86_64-arm64-apple-ios13.0-macabi'
  # set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} "-target x86_64-arm64-apple-ios12.0-macabi -isystem ${CMAKE_OSX_SYSROOT}/System/iOSSupport/usr/include")
  # set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} "-target x86_64-arm64-apple-ios12.0-macabi -isystem ${CMAKE_OSX_SYSROOT}/System/iOSSupport/usr/include")
  # set(CMAKE_THREAD_LIBS_INIT "-lpthread")
  # set(CMAKE_HAVE_THREADS_LIBRARY 1)
  # set(CMAKE_USE_WIN32_THREADS_INIT 0)
  # set(CMAKE_USE_PTHREADS_INIT 1)
  # set(THREADS_PREFER_PTHREAD_FLAG ON)
endif()

project (addon)

add_definitions(-DNAPI_VERSION=4)

include_directories(${CMAKE_JS_INC})

file(GLOB SOURCE_FILES "addon.c")

set(PROJECT_VERSION ${RELEASE_VERSION})

add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES} ${CMAKE_JS_SRC})

if(APPLE)
  # https://github.com/facebook/hermes/blob/2facf5b28f6ae68f7faa6df8c58341b305b2d5d3/API/hermes/CMakeLists.txt#L118
  set_target_properties(${PROJECT_NAME} PROPERTIES
    FRAMEWORK TRUE
    LINK_FLAGS "-undefined dynamic_lookup"
    # - If unset, your binary gets stored under `addon.framework/Versions/A/`.
    #   This approach is used by XcodeKit.framework.
    # - Python3.framework stores its v3.9.6 binary under the 3.9/ folder.
    # - hermes.framework stores its v0.12.0 binary under the 0/ folder.
    FRAMEWORK_VERSION ${PROJECT_VERSION}
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION}
    MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_FRAMEWORK_IDENTIFIER "dev.addon.${ADDON_TARGET_PLATFORM}"
  )
endif()

target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
  # Generate node.lib
  execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()
