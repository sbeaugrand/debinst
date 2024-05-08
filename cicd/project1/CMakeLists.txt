# ---------------------------------------------------------------------------- #
## \file CMakeLists.txt
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
set(PROJECT project-one)

cmake_minimum_required(VERSION 3.18)
project(${PROJECT})
include(../makefiles/include.cmake)
include(../makefiles/qt.cmake)

find_package(Qt5 REQUIRED COMPONENTS Widgets)

add_executable(${PROJECT}
    mainwindow.cpp
    main.cpp
    messagejob.cpp
)
target_link_libraries(${PROJECT} PRIVATE Qt5::Widgets)
target_link_libraries(${PROJECT} PRIVATE rabbitmq)
