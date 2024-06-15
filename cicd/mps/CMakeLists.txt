# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
cmake_minimum_required(VERSION 3.18)
include(../makefiles/xc.cmake)
project(mps)
include(../makefiles/include.cmake)

add_executable(mpserver
    mpserver.cpp
    List.cpp
    Player.cpp
    Server.cpp
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
if(XC)
    target_link_libraries(mpclient
        lirc_client
        upm-lcd
    )
endif()

add_executable(mpssaver
    mpssaver.cpp
    Input.cpp
    Output.cpp
)
if(XC)
    target_link_libraries(mpssaver
        lirc_client
        upm-lcd
    )
endif()

if(XC)
    add_executable(oledmesg
        oledmesg.cpp
    )
    target_link_libraries(oledmesg
        upm-lcd
    )
endif()
