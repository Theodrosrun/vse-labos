cmake_minimum_required(VERSION 3.13)

project(VSE_contract)

set(CMAKE_CXX_STANDARD 17)

add_executable(VSE_contract
    contract.h syntaxtree.h doublelinkedlist.h main.cpp)

target_link_libraries(VSE_contract PRIVATE gtest)

