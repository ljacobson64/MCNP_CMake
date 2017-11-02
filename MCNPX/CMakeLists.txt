message("")

set(LINK_LIBS)

# Source files
file(GLOB SRC_FILES
  "Source/src/mcnpx/dedx/*.F"
  "Source/src/mcnpx/f77main/*.F"
  "Source/src/mcnpx/fluka89/*.F"
  "Source/src/mcnpx/gvaviv/*.F"
  "Source/src/mcnpx/hexs/*.F"
  "Source/src/mcnpx/histp/*.F"
  "Source/src/mcnpx/lcs/*.F"
  "Source/src/mcnpx/mcnpc/mcnpc.c"
  "Source/src/mcnpx/mcnpc/*.cc"
  "Source/src/mcnpx/mcnpf/*.F"
  "Source/src/mcnpx/meshtal/*.F"
  "Source/src/mcnpx/spabi/*.F"
)

# Figure out which version of MCNP we're compiling based on which source files are present
set(MCNP_VERSION Unknown)
if ("/${SRC_FILES};" MATCHES "/main.F;")
  set(MCNP_VERSION 2.7.0)
endif ()
if (MCNP_VERSION STREQUAL "Unknown")
  message(FATAL_ERROR "MCNPX source files not found in MCNPX/Source/src")
endif ()
message(STATUS "MCNPX version ${MCNP_VERSION} source files found")

# Include directories
include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/src/include)

# Preprocessor directives
add_definitions(-DKODE="mcnpx")
add_definitions(-DVERS="2.7.0")
add_definitions(-DLODDAT="${ENV_DATE}")
add_definitions(-DMESHTAL=ON)
add_definitions(-DRADIOG=ON)
add_definitions(-DCEM=ON)
add_definitions(-DHISTP=ON)
add_definitions(-DSPABI=ON)
add_definitions(-DDFACT=ON)
add_definitions(-DXS64=ON)
add_definitions(-DINCL=ON)
add_definitions(-DCINDER=ON)
add_definitions(-DLAQGSM=ON)
add_definitions(-DNO_PAW=ON)
add_definitions(-DLINUX=ON)
add_definitions(-DUNIX=ON)
add_definitions(-DCHEAP=ON)
if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  add_definitions(-DINTEL=ON)
else ()
  add_definitions(-DGFORT=ON)
endif ()
add_definitions(-DF90=ON)

# Make sure DATAPATH is set
if (MCNPX_DATAPATH)
  add_definitions(-DDPATH="${MCNPX_DATAPATH}")
else ()
  if (DEFINED ENV{DATAPATH})
    add_definitions(-DDPATH="$ENV{DATAPATH}")
  else ()
    message(FATAL_ERROR "MCNPX DATAPATH not set. Either the environment variable DATAPATH or the CMake variable DMCNPX_DATAPATH must be set.")
  endif ()
endif ()

# MCNP Plotter
if (MCNP_PLOT)
  find_package(X11 REQUIRED)
  add_definitions(-DPLOT=ON)
  add_definitions(-DMCPLOT=ON)
  add_definitions(-DGKSSIM=ON)
  add_definitions(-DXLIB=ON)
  list(APPEND LINK_LIBS ${X11_LIBRARIES})
  if (BUILD_STATIC_EXE)
    list(APPEND LINK_LIBS xcb pthread Xau Xdmcp)
  endif ()
endif ()

# MPI
if (MPI_BUILD)
  find_package(MPI REQUIRED)
  add_definitions(-DMULTP=ON)
  add_definitions(-DMPI=ON)
  list(APPEND LINK_LIBS ${MPI_Fortran_LIBRARIES})
  include_directories(${MPI_INCLUDE_PATH})
endif ()

# Executable
if (MPI_BUILD)
  set(MCNP_EXEC "mcnpx_${MCNP_VERSION}.mpi")
  set(MCNP_EXEC_SYM "mcnpx.mpi")
else ()
  set(MCNP_EXEC "mcnpx_${MCNP_VERSION}")
  set(MCNP_EXEC_SYM "mcnpx")
endif ()

get_directory_property(COMPDEFS COMPILE_DEFINITIONS)
message(STATUS "MCNPX C_FLAGS: ${CMAKE_C_FLAGS}")
message(STATUS "MCNPX CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message(STATUS "MCNPX Fortran_FLAGS: ${CMAKE_Fortran_FLAGS}")
message(STATUS "MCNPX compile definitions: ${COMPDEFS}")

# Install
mcnp_install_exe(${MCNP_EXEC})
set_target_properties(${MCNP_EXEC} PROPERTIES LINKER_LANGUAGE Fortran)
mcnp_symlink_exe(${MCNP_EXEC} ${MCNP_EXEC_SYM})
