cmake_minimum_required(VERSION 3.26)
project(AoC C)

set(CMAKE_C_STANDARD 23)

add_executable(AoC main.c)
configure_file(input1.txt ${CMAKE_CURRENT_BINARY_DIR}/input1.txt COPYONLY)