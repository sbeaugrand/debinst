# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
set(PROJECT project-nine)

cmake_minimum_required(VERSION 3.18)
project(${PROJECT})
include(../makefiles/include.cmake)

include_directories(
    /usr/include/socket++
)

set(CLIENT client)
add_executable(${CLIENT}
    client.cpp
)
target_link_libraries(${CLIENT} PRIVATE socket++)

set(SERVER server)
add_executable(${SERVER}
    server.cpp
)
target_link_libraries(${SERVER} PRIVATE socket++)
