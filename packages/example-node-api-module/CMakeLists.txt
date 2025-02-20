cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0042 NEW)

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

  set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2")
  set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
  # TODO: get iOS/tvOS/visionOS deployment target. For now, we just pass iOS.
  set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0")
elseif(SDK_NAME STREQUAL "macosx")
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
  unset(BUILD_FRAMEWORK)
  set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE INTERNAL "" FORCE)
else()
  message(FATAL_ERROR "Unknown SDK name: ${SDK_NAME}")
  return()
endif()

project (addon)

add_definitions(-DNAPI_VERSION=4)

include_directories(${CMAKE_JS_INC})

file(GLOB SOURCE_FILES "addon.c")

add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES} ${CMAKE_JS_SRC})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".node")
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
  # Generate node.lib
  execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()
