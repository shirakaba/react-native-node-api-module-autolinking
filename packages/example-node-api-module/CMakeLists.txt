cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0042 NEW)

project(addon)

add_definitions(-DNAPI_VERSION=4)

include_directories(${CMAKE_JS_INC})

file(GLOB SOURCE_FILES "addon.c")

# Define a function to create a build target with specific parameters
# TODO: Read https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-ios-tvos-visionos-or-watchos
function(add_node_api_target SDK_NAME ARCHITECTURE)
  set(TARGET_NAME "${PROJECT_NAME}-${SDK_NAME}-${ARCHITECTURE}")
  add_library(${TARGET_NAME} SHARED ${SOURCE_FILES} ${CMAKE_JS_SRC})
  set_target_properties(${TARGET_NAME} PROPERTIES
    PREFIX ""
    SUFFIX ".node"
    CMAKE_OSX_ARCHITECTURES "${ARCHITECTURE}"
  )
  target_link_libraries(${TARGET_NAME} ${CMAKE_JS_LIB})

  if(SDK_NAME STREQUAL "macosx")
    set_target_properties(${TARGET_NAME} PROPERTIES
      XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "10.15"
      CMAKE_OSX_DEPLOYMENT_TARGET "13.0"
    )
  elseif(SDK_NAME STREQUAL "iphoneos" OR SDK_NAME STREQUAL "iphonesimulator")
    set_target_properties(${TARGET_NAME} PROPERTIES
      XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
      XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "13.0"
      XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    )
  endif()
endfunction()

# Wonder whether we should try valid archs instead

add_node_api_target("macosx" "arm64")
add_node_api_target("macosx" "x86_64")
add_node_api_target("iphoneos" "arm64")
add_node_api_target("iphoneos" "arm64e")
add_node_api_target("iphonesimulator" "arm64")
add_node_api_target("iphonesimulator" "x86_64")
