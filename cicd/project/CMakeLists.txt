cmake_minimum_required(VERSION 3.18)

project(project VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 REQUIRED COMPONENTS Widgets)

add_executable(project
    mainwindow.cpp
    main.cpp
    messagejob.cpp
)

target_link_libraries(project PRIVATE Qt5::Widgets)
target_link_libraries(project PRIVATE rabbitmq)
