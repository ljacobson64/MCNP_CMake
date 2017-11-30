message("")

set(LINK_LIBS)

# Source files
file(GLOB SRC_FILES
  "Source/mcnpx/dedx/*.F"
  "Source/mcnpx/f77main/*.F"
  "Source/mcnpx/fluka89/*.F"
  "Source/mcnpx/gvaviv/*.F"
  "Source/mcnpx/hexs/*.F"
  "Source/mcnpx/histp/*.F"
  "Source/mcnpx/lcs/*.F"
  "Source/mcnpx/mcnpc/mcnpc.c"
  "Source/mcnpx/mcnpc/*.cc"
  "Source/mcnpx/mcnpf/*.F"
  "Source/mcnpx/meshtal/*.F"
  "Source/mcnpx/spabi/*.F"
)

set(MCNP_VERSION X27)
if ("/${SRC_FILES};" MATCHES "/main.F90;")
  message(STATUS "MCNP${MCNP_VERSION} source files found")
else ()
  message(FATAL_ERROR "MCNP${MCNP_VERSION} source files not found in MCNP${MCNP_VERSION}/Source")
endif ()

# Include directories
include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/include)

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
if (MCNP${MCNP_VERSION}_DATAPATH)
  add_definitions(-DDPATH="${MCNP${MCNP_VERSION}_DATAPATH}")
else ()
  if (DEFINED ENV{DATAPATH})
    add_definitions(-DDPATH="$ENV{DATAPATH}")
  else ()
    message(FATAL_ERROR "MCNP${MCNP_VERSION} DATAPATH not set. Either the environment variable DATAPATH or the CMake variable DMCNP${MCNP_VERSION}_DATAPATH must be set.")
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
    list(APPEND LINK_LIBS xcb pthread Xau Xdmcp dl)
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
  set(MCNP_EXEC "mcnpx27.mpi")
  set(MCNP_EXEC_SYM "mcnpx.mpi")
else ()
  set(MCNP_EXEC "mcnpx27")
  set(MCNP_EXEC_SYM "mcnpx")
endif ()

get_directory_property(COMPDEFS COMPILE_DEFINITIONS)
message(STATUS "MCNP${MCNP_VERSION} C_FLAGS: ${CMAKE_C_FLAGS}")
message(STATUS "MCNP${MCNP_VERSION} CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message(STATUS "MCNP${MCNP_VERSION} Fortran_FLAGS: ${CMAKE_Fortran_FLAGS}")
message(STATUS "MCNP${MCNP_VERSION} compile definitions: ${COMPDEFS}")

# Install
mcnp_install_exe(${MCNP_EXEC})
set_target_properties(${MCNP_EXEC} PROPERTIES LINKER_LANGUAGE Fortran)
mcnp_symlink_exe(${MCNP_EXEC} ${MCNP_EXEC_SYM})
