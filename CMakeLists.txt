project(MCNP)

cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0004 OLD)
if (CMAKE_MAJOR_VERSION GREATER 3 OR CMAKE_MAJOR_VERSION EQUAL 3)
  cmake_policy(SET CMP0040 OLD)
endif (CMAKE_MAJOR_VERSION GREATER 3 OR CMAKE_MAJOR_VERSION EQUAL 3)

macro(create_symlink_bin exec exec_sym)
  install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${exec} ${exec_sym} \
                                WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${INSTALL_BIN_DIR})")
endmacro(create_symlink_bin exec exec_sym)

enable_language(Fortran)

# Clear out some variables automatically set by CMake
set(CMAKE_C_IMPLICIT_LINK_LIBRARIES "")
set(CMAKE_C_IMPLICIT_LINK_DIRECTORIES "")
set(CMAKE_CXX_IMPLICIT_LINK_LIBRARIES "stdc++")
set(CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES "")
set(CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES "")
set(CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES "")

# Installation directories
set(INSTALL_BIN_DIR     bin     CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR     lib     CACHE PATH "Installation directory for libraries")
set(INSTALL_INCLUDE_DIR include CACHE PATH "Installation directory for header files")
set(INSTALL_SHARE_DIR   share   CACHE PATH "Installation directory for other files")

# Default to Release build
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif (NOT CMAKE_BUILD_TYPE)

# Optimization flags: disable anything greater than -O1
set(CMAKE_C_FLAGS_RELEASE "-O1")
set(CMAKE_CXX_FLAGS_RELEASE "-O1")
set(CMAKE_Fortran_FLAGS_RELEASE "-O1")
if (NOT ${CMAKE_BUILD_TYPE})
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O1")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O1")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O1")
endif (NOT ${CMAKE_BUILD_TYPE})

# Determine if we're building static executables
option(BUILD_STATIC "Build static executables" OFF)
if (BUILD_STATIC)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
  set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS)
else ()
  set(BUILD_SHARED ON)
  if (${CMAKE_C_COMPILER_ID} STREQUAL Clang)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
  endif (${CMAKE_C_COMPILER_ID} STREQUAL Clang)
  if (${CMAKE_CXX_COMPILER_ID} STREQUAL Clang)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  endif (${CMAKE_CXX_COMPILER_ID} STREQUAL Clang)
endif (BUILD_STATIC)

# Linker flags
if (${CMAKE_Fortran_COMPILER_ID} STREQUAL Intel)
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-intel")
endif ()

# Get date and time
# modifed from http://www.cmake.org/pipermail/cmake/2010-November/041034.html
macro (DATETIME RESULT)
  execute_process(COMMAND "date" "+%d/%m/%Y" OUTPUT_VARIABLE ${RESULT})
  string(REGEX REPLACE "(..)/(..)/..(..).*" "\"\\2/\\1/\\3\"" ${RESULT} ${${RESULT}})
endmacro (DATETIME)
DATETIME(DATE)

# Figure out which physics codes to build
if (BUILD_ALL)
  set(BUILD_MCNP5 ON)
  set(BUILD_MCNPX ON)
  set(BUILD_MCNP6 ON)
  set(BUILD_MCNP611 ON)
endif (BUILD_ALL)

# Build MCNP
if (BUILD_MCNP5)
  add_subdirectory(MCNP5)
endif (BUILD_MCNP5)
if (BUILD_MCNPX)
  add_subdirectory(MCNPX)
endif (BUILD_MCNPX)
if (BUILD_MCNP6)
  add_subdirectory(MCNP6)
endif (BUILD_MCNP6)
if (BUILD_MCNP611)
  add_subdirectory(MCNP611)
endif (BUILD_MCNP611)
