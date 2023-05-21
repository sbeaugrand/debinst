QT += core widgets
TARGET = project-one
TEMPLATE = app 
CONFIG += c++20
QMAKE_CXXFLAGS += -std=c++20
SOURCES += main.cpp mainwindow.cpp messagejob.cpp
HEADERS += mainwindow.h messagejob.h
LIBS += -lrabbitmq
