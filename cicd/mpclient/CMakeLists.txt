# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
set(PROJECT mpclient)

cmake_minimum_required(VERSION 3.18)
include(../makefiles/xc.cmake)
project(${PROJECT})
include(../makefiles/include.cmake)

add_executable(${PROJECT}
    main.cpp
    Input.cpp
    Output.cpp
    Client.cpp
    common.cpp
)

target_link_libraries(${PROJECT} PRIVATE jsoncpp)
target_link_libraries(${PROJECT} PRIVATE jsonrpccpp-common)
target_link_libraries(${PROJECT} PRIVATE jsonrpccpp-client)
if(XC)
    target_link_libraries(${PROJECT} PRIVATE "-lupm-lcd")
endif()
