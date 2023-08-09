# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Only cross compile for armhf (Nanopi Neo) with sysroot
##       mkdir build && cd build
##       cmake .. -DCMAKE_SYSROOT=/data/armhf
##       make
# ---------------------------------------------------------------------------- #
set(PROJECT mp3server)
cmake_minimum_required(VERSION 3.18)
project(${PROJECT})

if(CMAKE_SYSROOT)
    SET(XC arm-linux-gnueabihf)
    SET(CXXVER 10)
    SET(CMAKE_C_COMPILER ${XC}-gcc)
    SET(CMAKE_CXX_COMPILER ${XC}-g++)
endif()

include(include.cmake)
add_compile_options(
    "-g" "-DNDEBUG" "-nostdinc"
)

if(CMAKE_SYSROOT)
    include_directories(
	${CMAKE_SYSROOT}/usr/lib/gcc/${XC}/${CXXVER}/include
	${CMAKE_SYSROOT}/usr/include/${XC}
    )
    set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES
	${CMAKE_SYSROOT}/usr/include
    )
    set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
	${CMAKE_SYSROOT}/usr/include/c++/${CXXVER}
	${CMAKE_SYSROOT}/usr/include/${XC}/c++/${CXXVER}
	${CMAKE_SYSROOT}/usr/include
    )
    link_directories(
	${CMAKE_SYSROOT}/usr/lib/gcc/${XC}/${CXXVER}
	${CMAKE_SYSROOT}/usr/lib/${XC}
    )
endif()

set(SERVER server)
add_executable(${SERVER}
    mp3server.c
    player-xmms.c
    httpServer.c
    resources.c
    log.c
    html.c
    common.c
)
target_include_directories(${SERVER} PRIVATE
    ${CMAKE_SYSROOT}/usr/include/xmms2
    ../debug
)
target_link_libraries(${SERVER} PRIVATE
    xmmsclient
)

set(CLIENT client)
add_executable(${CLIENT}
    mp3client.c
    common.c
    setup.c
    oled.cpp
    lirc.c
)
target_include_directories(${CLIENT} PRIVATE
    ${CMAKE_SYSROOT}/usr/local/include
    ${CMAKE_SYSROOT}/usr/local/include/upm
    ../debug
)
target_link_libraries(${CLIENT} PRIVATE
    upm-lcd
    lirc_client
)
