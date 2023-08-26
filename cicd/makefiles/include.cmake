# ---------------------------------------------------------------------------- #
## \file include.cmake
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if(XC)
    if(NOT DEFINED XCVER)
        set(XCVER 12)
    endif()
    if(NOT DEFINED XCDIR)
        set(XCDIR /data)
    endif()
    set(CMAKE_C_COMPILER ${XC}-gcc)
    set(CMAKE_CXX_COMPILER ${XC}-g++)
    set(CMAKE_SYSROOT ${XCDIR}/${XC}-${XCVER})
    message("CMAKE_SYSROOT=${CMAKE_SYSROOT}")
    add_compile_options(
        # Try it or comment it
        "-nostdinc"
    )
    include_directories(
        ${CMAKE_SYSROOT}/usr/lib/gcc/${XC}/${XCVER}/include
        ${CMAKE_SYSROOT}/usr/include/${XC}
    )
    set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES
        ${CMAKE_SYSROOT}/usr/include
        ${CMAKE_SYSROOT}/usr/local/include
    )
    set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
        ${CMAKE_SYSROOT}/usr/include/c++/${XCVER}
        ${CMAKE_SYSROOT}/usr/include/${XC}/c++/${XCVER}
        ${CMAKE_SYSROOT}/usr/include
        ${CMAKE_SYSROOT}/usr/local/include
    )
    link_directories(
        ${CMAKE_SYSROOT}/usr/lib/gcc/${XC}/${XCVER}
        ${CMAKE_SYSROOT}/usr/lib/${XC}
    )
    if(USE_QT)
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
endif()

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++20" COMPILER_SUPPORTS_CXX20)
if(COMPILER_SUPPORTS_CXX20)
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_EXTENSIONS OFF)
else()
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_EXTENSIONS OFF)
endif()

add_compile_options(
    "-Wall" "-Wextra" "-O1" "-D_FORTIFY_SOURCE=2" "-Wfatal-errors"
)

if(USE_QT)
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOUIC ON)
endif()
