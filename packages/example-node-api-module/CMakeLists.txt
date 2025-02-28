include(CMakePrintHelpers)

cmake_print_variables(ADDON_TARGET_PLATFORM CMAKE_XCODE_ATTRIBUTE_SUPPORTS_MACCATALYST CMAKE_OSX_DEPLOYMENT_TARGET CMAKE_JS_INC)

# - v3.28 is the minimum that supports visionOS.
# - v3.31 is the minimum that support Catalyst.
cmake_minimum_required(VERSION 3.31)
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0042 NEW)

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

# It sounds like `--undefined dynamic_lookup` is Apple-specific, so for Android
# I am trying `--unresolved-symbols=ignore-all`.
# target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB} PRIVATE -Wl,--unresolved-symbols=ignore-all)

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
  # Generate node.lib
  execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()
