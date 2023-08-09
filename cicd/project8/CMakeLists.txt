# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
set(PROJECT project-eight)

cmake_minimum_required(VERSION 3.18)
project(${PROJECT})
include(../makefiles/include.cmake)

set(CLIENT client)
add_executable(${CLIENT}
    client.cpp
)
target_link_libraries(${CLIENT} PRIVATE cpp-httplib)

set(SERVER ${PROJECT})
add_executable(${SERVER}
    Server.cpp
    main.cpp
)
target_link_libraries(${SERVER} PRIVATE cpp-httplib)
