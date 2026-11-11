# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
cmake_minimum_required(VERSION 3.18)
include(${PICO_SDK_PATH}/pico_sdk_init.cmake)
project(rc-switch)
pico_sdk_init()

add_subdirectory(../CH9120 CH9120)
include_directories(../CH9120)

add_executable(main
    main.c
)

target_link_libraries(main CH9120 hardware_pio)

option(NTP_CLOCK "7-segment display of NTP time" OFF)
if(NTP_CLOCK)
    target_sources(main PRIVATE clock.c)
    target_compile_definitions(main PRIVATE NTP_CLOCK)
endif()

pico_enable_stdio_usb(main 1)
pico_add_extra_outputs(main)

pico_generate_pio_header(main ${CMAKE_CURRENT_LIST_DIR}/rc-switch.pio)
