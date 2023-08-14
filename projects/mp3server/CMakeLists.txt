# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Only cross compile for arm with sysroot
##       See ../../cicd/remotehost-xc/README.md
##       mkdir build- && cd build-
##       cmake .. -DXC=aarch64-linux-gnu  # or :
##       cmake .. -DXC=arm-linux-gnueabihf -DXCVER=10
##       make
# ---------------------------------------------------------------------------- #
set(PROJECT mp3server)

cmake_minimum_required(VERSION 3.18)
project(${PROJECT})
include(../../cicd/makefiles/include.cmake)

add_compile_options(
    "-g"
    "-DNDEBUG"
    "-DMPD"
)

set(SERVER mp3server)
add_executable(${SERVER}
    mp3server.c
    #player-xmms.c
    player-mpd.c
    httpServer.c
    resources.c
    log.c
    html.c
    common.c
)
target_include_directories(${SERVER} PRIVATE
    #${CMAKE_SYSROOT}/usr/include/xmms2
    ../debug
)
target_link_libraries(${SERVER} PRIVATE
    #xmmsclient
    mpdclient
)

set(CLIENT mp3client)
add_executable(${CLIENT}
    mp3client.c
    common.c
    setup.c
    oled.cpp
    lirc.c
)
target_include_directories(${CLIENT} PRIVATE
    ${CMAKE_SYSROOT}/usr/local/include/upm
    ../debug
)
target_link_libraries(${CLIENT} PRIVATE
    upm-lcd
    lirc_client
)
