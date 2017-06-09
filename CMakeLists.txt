project(MCNP)

cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0004 OLD)
if (CMAKE_MAJOR_VERSION GREATER 3 OR CMAKE_MAJOR_VERSION EQUAL 3)
  cmake_policy(SET CMP0040 OLD)
endif (CMAKE_MAJOR_VERSION GREATER 3 OR CMAKE_MAJOR_VERSION EQUAL 3)

enable_language(Fortran)

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
else ()
  set(BUILD_SHARED ON)
endif (BUILD_STATIC)

# Figure out which physics codes to build
if (BUILD_ALL)
  set(BUILD_MCNP5 ON)
  set(BUILD_MCNP6 ON)
  set(BUILD_MCNP611 ON)
endif (BUILD_ALL)

# Build MCNP
if (BUILD_MCNP5)
  add_subdirectory(MCNP5)
endif (BUILD_MCNP5)
if (BUILD_MCNP6)
  add_subdirectory(MCNP6)
endif (BUILD_MCNP6)
if (BUILD_MCNP611)
  add_subdirectory(MCNP611)
endif (BUILD_MCNP611)
