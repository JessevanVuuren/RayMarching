cmake_minimum_required(VERSION 3.31)

# https://raytracing.github.io/books/RayTracingInOneWeekend.html
# https://iquilezles.org/articles/distfunctions/
# https://www.cs.cornell.edu/courses/cs4620/2011fa/lectures/08raytracingWeb.pdf
# https://lavalle.pl/vr/node197.html


# cmake -S . -B build -G "MinGW Makefiles"
# cmake --build .\build\ && .\build\ray_marching.exe > ./imgs/render.ppm

set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

project(ray_marching)

set (RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

add_executable(ray_marching main.cc)