cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0042 NEW)

if(APPLE)
  # https://github.com/facebook/hermes/blob/2facf5b28f6ae68f7faa6df8c58341b305b2d5d3/hermes-engine.podspec#L27
  # https://github.com/facebook/hermes/blob/2facf5b28f6ae68f7faa6df8c58341b305b2d5d3/utils/build-apple-framework.sh#L32-L46
  set(ADDON_IPHONEOS_DEPLOYMENT_TARGET "12.0" CACHE INTERNAL "Deployment target for iphoneos and related SDKs.")
  set(ADDON_MACOSX_DEPLOYMENT_TARGET "10.13" CACHE INTERNAL "Deployment target for macOS and related SDKs.")
  set(ADDON_TVOS_DEPLOYMENT_TARGET "12.0" CACHE INTERNAL "Deployment target for tvOS and related SDKs.")
  set(ADDON_VISIONOS_DEPLOYMENT_TARGET "1.0" CACHE INTERNAL "Deployment target for visionOS and related SDKs.")

  # With reference to:
  # https://github.com/NativeScript/runtime-node-api/blob/29151c404044ddb1f9270c64b1bbcc249db6352d/CMakeLists.txt#L22
  if(
    SDK_NAME STREQUAL "iphoneos" OR
    SDK_NAME STREQUAL "iphonesimulator" OR
    SDK_NAME STREQUAL "catalyst" OR
    SDK_NAME STREQUAL "xros" OR
    SDK_NAME STREQUAL "xrsimulator" OR
    SDK_NAME STREQUAL "appletvos" OR
    SDK_NAME STREQUAL "appletvsimulator"
  )
    # https://github.com/facebook/hermes/blob/2facf5b28f6ae68f7faa6df8c58341b305b2d5d3/utils/build-ios-framework.sh#L14-L20
    if(
      SDK_NAME STREQUAL "iphoneos" OR
      SDK_NAME STREQUAL "xros" OR
      SDK_NAME STREQUAL "xrsimulator" OR
      SDK_NAME STREQUAL "appletvos"
    )
      set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE INTERNAL "" FORCE)
    else()
      set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE INTERNAL "" FORCE)
    endif()

    # https://github.com/facebook/hermes/blob/2facf5b28f6ae68f7faa6df8c58341b305b2d5d3/utils/build-apple-framework.sh#L58-L62
    if(
      SDK_NAME STREQUAL "iphoneos" OR
      SDK_NAME STREQUAL "xros" OR
      SDK_NAME STREQUAL "catalyst" OR
      SDK_NAME STREQUAL "appletvos"
    )
      set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "YES")
    else()
      set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
    endif()

    # https://github.com/facebook/hermes/blob/2facf5b28f6ae68f7faa6df8c58341b305b2d5d3/utils/build-ios-framework.sh#L14-L20
    if(
      SDK_NAME STREQUAL "iphoneos" OR
      SDK_NAME STREQUAL "iphonesimulator" OR
      SDK_NAME STREQUAL "catalyst"
    )
      set(CMAKE_OSX_DEPLOYMENT_TARGET "${ADDON_IPHONEOS_DEPLOYMENT_TARGET}")
    elseif(
      SDK_NAME STREQUAL "xros" OR
      SDK_NAME STREQUAL "xrsimulator"
    )
      set(CMAKE_OSX_DEPLOYMENT_TARGET "${ADDON_VISIONOS_DEPLOYMENT_TARGET}")
    elseif(
      SDK_NAME STREQUAL "appletvos" OR
      SDK_NAME STREQUAL "appletvsimulator"
    )
      set(CMAKE_OSX_DEPLOYMENT_TARGET "${ADDON_TVOS_DEPLOYMENT_TARGET}")
    endif()
  elseif(SDK_NAME STREQUAL "macosx")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "${ADDON_MACOSX_DEPLOYMENT_TARGET}")
    # unset(BUILD_FRAMEWORK)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE INTERNAL "" FORCE)
  else()
    message(FATAL_ERROR "Unknown SDK name: ${SDK_NAME}")
    return()
  endif()
endif()

project (addon)

add_definitions(-DNAPI_VERSION=4)

include_directories(${CMAKE_JS_INC})

file(GLOB SOURCE_FILES "addon.c")

set(PROJECT_VERSION "1.2.3")

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
    MACOSX_FRAMEWORK_IDENTIFIER dev.addon.${SDK_NAME}
  )
endif()

target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
  # Generate node.lib
  execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()
