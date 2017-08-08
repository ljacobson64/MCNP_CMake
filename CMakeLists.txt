project(MCNP)

cmake_minimum_required(VERSION 3.6)

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
  message(STATUS "CMAKE_BUILD_TYPE not specified, defaulting to Release")
  set(CMAKE_BUILD_TYPE Release)
endif (NOT CMAKE_BUILD_TYPE)
if (NOT CMAKE_BUILD_TYPE STREQUAL "Release" AND
    NOT CMAKE_BUILD_TYPE STREQUAL "Debug" AND
    NOT CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  message(FATAL_ERROR "Specified CMAKE_BUILD_TYPE is invalid; valid options are Release, Debug, RelWithDebInfo")
endif ()
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

# Optimization flags: disable anything greater than -O1
set(CMAKE_C_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_Fortran_FLAGS_DEBUG "-g")
set(CMAKE_C_FLAGS_RELEASE "-O1")
set(CMAKE_CXX_FLAGS_RELEASE "-O1")
set(CMAKE_Fortran_FLAGS_RELEASE "-O1")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O1 -g")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O1 -g")
set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-O1 -g")

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

# Get some environment variables
set(ENV_USER "$ENV{USER}")
execute_process(COMMAND hostname       OUTPUT_VARIABLE ENV_HOST OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND uname -s       OUTPUT_VARIABLE ENV_OS   OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND date +%m/%d/%y OUTPUT_VARIABLE ENV_DATE OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND date +%H:%M:%S OUTPUT_VARIABLE ENV_TIME OUTPUT_STRIP_TRAILING_WHITESPACE)

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
