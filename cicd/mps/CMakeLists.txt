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
        OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL aarch64
        OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL armv7l)
    target_link_libraries(mpclient
        lirc_client
        upm-lcd
    )
    target_link_libraries(mpssaver
        lirc_client
        upm-lcd
    )
endif()

add_custom_command(
    OUTPUT mpserver.1
    COMMAND help2man -N -o mpserver.1 -n 'music player server' ./mpserver || cp ../mpserver.1 .
    DEPENDS mpserver
)
add_custom_command(
    OUTPUT mpclient.1
    COMMAND help2man -N -o mpclient.1 -n 'music player client' ./mpclient || cp ../mpclient.1 .
    DEPENDS mpclient
)
add_custom_command(
    OUTPUT mpssaver.1
    COMMAND help2man -N -o mpssaver.1 -n 'music player screensaver' ./mpssaver || cp ../mpssaver.1 .
    DEPENDS mpssaver
)
add_custom_command(
    OUTPUT oledmesg.1
    COMMAND help2man -N -o oledmesg.1 -n 'display a message in oled module' ./oledmesg || cp ../oledmesg.1 .
    DEPENDS oledmesg
)

add_custom_target(mpserver-manpage ALL DEPENDS mpserver.1)
add_custom_target(mpclient-manpage ALL DEPENDS mpclient.1)
add_custom_target(mpssaver-manpage ALL DEPENDS mpssaver.1)
add_custom_target(oledmesg-manpage ALL DEPENDS oledmesg.1)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/mpserver.1
    ${CMAKE_CURRENT_BINARY_DIR}/mpclient.1
    ${CMAKE_CURRENT_BINARY_DIR}/mpssaver.1
    ${CMAKE_CURRENT_BINARY_DIR}/oledmesg.1
    DESTINATION share/man/man1
)
