cmake_minimum_required(VERSION 3.16)
project(Embedded)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "-Wall")
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "-g")

# Library containing common code
add_library(embedded_lib
        src/fpgaAvalon.cpp
        src/spikeDetectorManager.cpp
        src/spikeDetectorUtils.cpp
)
target_include_directories(embedded_lib PUBLIC src)

# Main executable
add_executable(embedded_soft src/main.cpp)
target_link_libraries(embedded_soft PRIVATE embedded_lib)

# Tests
enable_testing()
include(FetchContent)
FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG v1.14.0
)
FetchContent_MakeAvailable(googletest)

include(GoogleTest) # Added this line to include GoogleTest module

# Test executable
add_executable(embedded_tests
        tests/mainTests.cpp
        tests/fpgaAvalonTests.cpp
        tests/spikeDetectorManagerTests.cpp
)

target_include_directories(embedded_tests PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/tests
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(embedded_tests PRIVATE
        embedded_lib
        GTest::gtest
        GTest::gmock
        pthread
)

gtest_discover_tests(embedded_tests)

# Integration tests executable
add_executable(integration_tests
        tests/mainTests.cpp
        tests/integration/baseIntegrationTests.h
        tests/integration/3SpikesInputTest.cpp
        tests/integration/defaultInputTest.cpp
        tests/integration/noSpikesInputTest.cpp
)

target_include_directories(integration_tests PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/integration
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(integration_tests PRIVATE
        embedded_lib
        GTest::gtest
        GTest::gmock
        pthread
)

gtest_discover_tests(integration_tests)
