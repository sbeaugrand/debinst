# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
cmake_minimum_required(VERSION 3.18)
include(xc.cmake)
project(mps)
include(include.cmake)
message(CMAKE_HOST_SYSTEM_PROCESSOR=${CMAKE_HOST_SYSTEM_PROCESSOR})

add_executable(mpserver
    mpserver.cpp
    List.cpp
    Player.cpp
    Server.cpp
    path.cpp
)
target_link_libraries(mpserver
    mpdclient
    jsoncpp
    jsonrpccpp-common
    jsonrpccpp-server
)

add_executable(mpclient
    mpclient.cpp
    Input.cpp
    Output.cpp
    Client.cpp
)
target_link_libraries(mpclient
    jsoncpp
    jsonrpccpp-common
    jsonrpccpp-client
)

add_executable(mpssaver
    mpssaver.cpp
    Input.cpp
    Output.cpp
)

add_executable(oledmesg
    oledmesg.cpp
)
target_link_libraries(oledmesg
    upm-lcd
)

install(TARGETS mpserver mpclient mpssaver oledmesg)

if(XC
        OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "aarch64"
        OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "armv7l")
    target_link_libraries(mpclient
        lirc_client
        upm-lcd
    )
    target_link_libraries(mpssaver
        lirc_client
        upm-lcd
    )
endif()
