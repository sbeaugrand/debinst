# ---------------------------------------------------------------------------- #
## \file include.cmake
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
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
