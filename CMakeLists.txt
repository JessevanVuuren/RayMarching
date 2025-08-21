cmake_minimum_required(VERSION 3.31)

# https://raytracing.github.io/books/RayTracingInOneWeekend.html
# cmake -S . -B build -G "MinGW Makefiles"
# cmake --build .\build\ && .\build\ray_marching.exe > ./imgs/render.ppm

set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

project(ray_marching)

set (RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

add_executable(ray_marching main.cc)