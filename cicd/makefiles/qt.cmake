# ---------------------------------------------------------------------------- #
## \file qt.cmake
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if(XC)
    if (NOT TARGET Qt5::qmake)
        add_executable(Qt5::qmake IMPORTED)
        set_target_properties(Qt5::qmake PROPERTIES
            IMPORTED_LOCATION /usr/lib/qt5/bin/qmake
        )
    endif()
    if (NOT TARGET Qt5::moc)
        add_executable(Qt5::moc IMPORTED)
        set_target_properties(Qt5::moc PROPERTIES
            IMPORTED_LOCATION /usr/lib/qt5/bin/moc
        )
        # For CMake automoc feature
        get_target_property(QT_MOC_EXECUTABLE Qt5::moc LOCATION)
    endif()
    if (NOT TARGET Qt5::rcc)
        add_executable(Qt5::rcc IMPORTED)
        set_target_properties(Qt5::rcc PROPERTIES
            IMPORTED_LOCATION /usr/lib/qt5/bin/rcc
        )
    endif()
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
