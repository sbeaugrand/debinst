# ---------------------------------------------------------------------------- #
## \file include.cmake
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if(XC)
    if(NOT DEFINED XCVER)
        set(XCVER 14)
    endif()
    if(NOT DEFINED XCDIR)
        set(XCDIR /data)
    endif()
    set(CMAKE_C_COMPILER ${XC}-gcc)
    set(CMAKE_CXX_COMPILER ${XC}-g++)
    set(CMAKE_SYSROOT ${XCDIR}/${XC}-${XCVER})
    set(CMAKE_PREFIX_PATH ${CMAKE_SYSROOT}/usr/lib/${XC})
    message("CMAKE_SYSROOT=${CMAKE_SYSROOT}")
    add_compile_options(
        # Try it or comment it
        "-nostdinc"
    )
    set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES
        ${CMAKE_SYSROOT}/usr/include
        ${CMAKE_SYSROOT}/usr/local/include
    )
    set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
        ${CMAKE_SYSROOT}/usr/lib/gcc/${XC}/${XCVER}/include
        ${CMAKE_SYSROOT}/usr/include/${XC}
        ${CMAKE_SYSROOT}/usr/include/c++/${XCVER}
        ${CMAKE_SYSROOT}/usr/include/${XC}/c++/${XCVER}
        ${CMAKE_SYSROOT}/usr/include
        ${CMAKE_SYSROOT}/usr/local/include
    )
    link_directories(
        ${CMAKE_SYSROOT}/usr/lib/gcc/${XC}/${XCVER}
        ${CMAKE_SYSROOT}/usr/lib/${XC}
    )
endif()
