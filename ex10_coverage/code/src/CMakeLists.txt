cmake_minimum_required(VERSION 3.13)

project(coverage_test)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_CXX_FLAGS "--coverage -O0")


add_executable(coverage_test
    main.cpp)

target_link_libraries(coverage_test PRIVATE gtest)

