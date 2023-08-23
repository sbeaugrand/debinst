# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
set(PROJECT project-six)

cmake_minimum_required(VERSION 3.18)
project(${PROJECT})
set(USE_QT true)
include(../makefiles/include.cmake)

find_package(Qt5 REQUIRED COMPONENTS WebSockets
    PATHS ${CMAKE_SYSROOT}/usr/lib/${XC}/cmake/Qt5 NO_DEFAULT_PATH)

set(CLIENT client)
add_executable(${CLIENT}
    client.cpp
)
target_link_libraries(${CLIENT} PRIVATE Qt5::WebSockets)

set(SERVER ${PROJECT})
add_executable(${SERVER}
    server.cpp
)
target_link_libraries(${SERVER} PRIVATE Qt5::WebSockets)
