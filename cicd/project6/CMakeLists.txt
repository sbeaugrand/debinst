# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
set(PROJECT project-five)

cmake_minimum_required(VERSION 3.18)
project(${PROJECT})
set(USE_QT true)
include(../makefiles/include.cmake)

find_package(Qt5 REQUIRED COMPONENTS WebSockets)

set(CLIENT client)
add_executable(${CLIENT}
    client.cpp
)
target_link_libraries(${CLIENT} PRIVATE Qt5::WebSockets)

set(SERVER server)
add_executable(${SERVER}
    server.cpp
)
target_link_libraries(${SERVER} PRIVATE Qt5::WebSockets)
