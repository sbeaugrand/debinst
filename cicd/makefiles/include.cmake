# ---------------------------------------------------------------------------- #
## \file include.cmake
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if(CMAKE_SYSROOT)
    SET(CMAKE_C_COMPILER ${XC}-gcc)
    SET(CMAKE_CXX_COMPILER ${XC}-g++)
    add_compile_options(
	"-nostdinc"
    )
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

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++20" COMPILER_SUPPORTS_CXX20)
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
