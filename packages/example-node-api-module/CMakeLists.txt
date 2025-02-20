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
  # unset(BUILD_FRAMEWORK)
  set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE INTERNAL "" FORCE)
else()
  message(FATAL_ERROR "Unknown SDK name: ${SDK_NAME}")
  return()
endif()

project (addon)

add_definitions(-DNAPI_VERSION=4)

include_directories(${CMAKE_JS_INC})

file(GLOB SOURCE_FILES "addon.c")

set(PROJECT_VERSION "1.2.3")
set(PROJECT_VERSION_MAJOR "1")

# It seems:
# If we want `FRAMEWORK TRUE`, we need STATIC to compile successfully.
# If we want `FRAMEWORK FALSE`, we can use SHARED or MODULE. We want SHARED, but
# it's not compiling.
# If no <type> is given for add_library, the default is STATIC or SHARED based
# on the value of the BUILD_SHARED_LIBS variable.
# If BUILD_SHARED_LIBS isn't specified, then the default library type is SHARED.
# https://cmake.org/cmake/help/latest/command/add_library.html

add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES} ${CMAKE_JS_SRC})
# https://github.com/facebook/hermes/blob/2facf5b28f6ae68f7faa6df8c58341b305b2d5d3/API/hermes/CMakeLists.txt#L118
set_target_properties(${PROJECT_NAME} PROPERTIES
  # PREFIX ""
  # SUFFIX ".node"
  FRAMEWORK TRUE
  # This is needed when the add_library() <type> is not STATIC (e.g. is SHARED).
  # However, this may not be allowed on the App Store as it's not part of a
  # system framework.
  LINK_FLAGS "-undefined dynamic_lookup"
  # VERSION ${PROJECT_VERSION}
  # SOVERSION ${PROJECT_VERSION}
  FRAMEWORK_VERSION ${PROJECT_VERSION_MAJOR}
  MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION}
  MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
  MACOSX_FRAMEWORK_IDENTIFIER dev.addon.${SDK_NAME}
)
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
  # Generate node.lib
  execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()
