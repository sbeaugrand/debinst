# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
set(PROJECT project-three)

cmake_minimum_required(VERSION 3.18)
include(../makefiles/xc.cmake)
project(${PROJECT})
include(../makefiles/include.cmake)

add_executable(${PROJECT}
    main.cpp
)
target_link_libraries(${PROJECT} PRIVATE SimpleAmqpClient)
