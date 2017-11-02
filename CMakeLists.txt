project(MCNP)
cmake_minimum_required(VERSION 2.8)
enable_language(Fortran)

# Make the scripts in the "cmake" directory available to CMake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
include(mcnp_macros)

mcnp_setup_build()
mcnp_setup_options()
mcnp_setup_flags()
mcnp_setup_rpath()

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

message("")
