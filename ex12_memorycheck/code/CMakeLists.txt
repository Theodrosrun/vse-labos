cmake_minimum_required(VERSION 3.13)

project(VSE_memorycheck)

option(ADDRESS_SANITIZER "Build with address sanitizer" OFF)
option(THREAD_SANITIZER "Build with address sanitizer" OFF)

if(ADDRESS_SANITIZER)
    message("Compiling with address sanitizer")
    set(CMAKE_CXX_FLAGS "-fsanitize=address")
    set(CMAKE_EXE_LINKER_FLAGS "-fsanitize=address")
endif()

if(THREAD_SANITIZER)
message("Compiling with thread sanitizer")
    set(CMAKE_CXX_FLAGS "-fsanitize=thread")
    set(CMAKE_EXE_LINKER_FLAGS "-fsanitize=thread")
endif()


set(CMAKE_CXX_STANDARD 17)

add_executable(VSE_memorycheck main.cpp)

target_link_libraries(VSE_memorycheck PRIVATE gtest)

