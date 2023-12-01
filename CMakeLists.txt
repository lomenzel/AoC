cmake_minimum_required(VERSION 3.26)
project(AoC C)

set(CMAKE_C_STANDARD 23)

add_executable(AoC main.c)
configure_file(test.txt ${CMAKE_CURRENT_BINARY_DIR}/test.txt COPYONLY)