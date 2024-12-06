cmake_minimum_required(VERSION 3.13)

project(VSE_unittests)

set(CMAKE_CXX_STANDARD 17)

add_executable(VSE_unittests
    cardriver.cpp floating.cpp mathcomputer.cpp myarray.cpp simplecompute.cpp main.cpp)

target_link_libraries(VSE_unittests PRIVATE gtest gmock)

