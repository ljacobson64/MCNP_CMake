message("")

set(LINK_LIBS)

# Source files
file(GLOB SRC_FILES
  "Source/dedx/*.F90"
  "Source/hexs/*.F90"
  "Source/import/*.cpp"
  "Source/import/*.f"
  "Source/import/*.F"
  "Source/import/*.F90"
  "Source/import/cgm/*.c"
  "Source/import/cgm/*.cpp"
  "Source/lcs/*.F90"
  "Source/meshtal/*.F90"
  "Source/regl/*.F90"
  "Source/spabi/*.F90"
  "Source/src/*.c"
  "Source/src/*.F90"
  "Source/src/partisn/*.F90"
  "Source/src/utils/*.c"
  "Source/src/utils/*.F90"
)

# Figure out which version of MCNP we're compiling based on which source files are present
set(MCNP_VERSION Unknown)
if ("/${SRC_FILES};" MATCHES "/cerenkov_mod.F90;" AND
    "/${SRC_FILES};" MATCHES "/cgm_interface.F90;" AND
    "/${SRC_FILES};" MATCHES "/parse_ichoic.F90;" AND
    "/${SRC_FILES};" MATCHES "/reflect_light.F90;")
  set(MCNP_VERSION 611)
endif ()
if (MCNP_VERSION STREQUAL "Unknown")
  message(FATAL_ERROR "MCNP611 source files not found in MCNP611/Source")
endif ()
message(STATUS "MCNP611 source files found")

# C compiler flags
if (CMAKE_C_COMPILER_ID STREQUAL "Intel")
  #set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcmodel=medium")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pc64")
else ()
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
endif ()

# Fortran compiler flags
if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -no-vec")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -heap-arrays 1024")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -traceback")
  #set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -mcmodel=medium")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -pc64")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -diag-disable 8290,8291,8577")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -r8")
else ()
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -m64")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -mieee-fp")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdollar-ok")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-sign-zero")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-real-8")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-double-8")
endif ()

# Include directories
include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/import)
include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/import/cgm)

# Preprocessor directives
add_definitions(-DKODE="mcnp")
add_definitions(-DTHREAD="MCNP")
add_definitions(-DTVERS="6.1.1b")
add_definitions(-DLODDAT="${ENV_DATE}")
add_definitions(-DLINUX=ON)
add_definitions(-DUNIX=ON)
if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  add_definitions(-DINTEL=ON)
  add_definitions(-DDIRACCESS_RECL_WORDS=ON)
else ()
  add_definitions(-DGFORTRAN=ON)
endif ()
add_definitions(-DLLNL_FISS=ON)
add_definitions(-DF90_INT_4BYTE=ON)
add_definitions(-DF90_REAL_8BYTE=ON)
add_definitions(-DCGM=ON)
add_definitions(-DCEM=ON)
add_definitions(-DCEM_M6=ON)
add_definitions(-DCINDER=ON)
add_definitions(-DLAQGSM=ON)
add_definitions(-DUOD=ON)
add_definitions(-DENV_USER="${ENV_USER}")
add_definitions(-DENV_HOST="${ENV_HOST}")
add_definitions(-DENV_OS="${ENV_OS}")
add_definitions(-DENV_DATE="${ENV_DATE}")
add_definitions(-DENV_TIME="${ENV_TIME}")
add_definitions(-DENV_CC="${CMAKE_C_COMPILER}")
add_definitions(-DENV_CXX="${CMAKE_CXX_COMPILER}")
add_definitions(-DENV_F90="${CMAKE_Fortran_COMPILER}")

# Make sure DATAPATH is set
if (MCNP611_DATAPATH)
  add_definitions(-DDPATH="${MCNP611_DATAPATH}")
else ()
  if (DEFINED ENV{DATAPATH})
    add_definitions(-DDPATH="$ENV{DATAPATH}")
  else ()
    message(FATAL_ERROR "MCNP611 DATAPATH not set. Either the environment variable DATAPATH or the CMake variable DMCNP611_DATAPATH must be set.")
  endif ()
endif ()

# MCNP Plotter
if (MCNP_PLOT)
  find_package(X11 REQUIRED)
  add_definitions(-DPLOT=ON)
  add_definitions(-DXLIB=ON)
  list(APPEND LINK_LIBS ${X11_LIBRARIES})
  if (BUILD_STATIC_EXE)
    list(APPEND LINK_LIBS xcb pthread Xau Xdmcp)
  endif ()
endif ()

# OpenMP
if (OPENMP_BUILD)
  find_package(OpenMP REQUIRED)
  add_definitions(-DOMP=ON)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${OpenMP_Fortran_FLAGS}")
endif ()

# MPI
if (MPI_BUILD)
  find_package(MPI REQUIRED)
  add_definitions(-DVERS="6.mpi")
  add_definitions(-DMPI=ON)
  list(APPEND LINK_LIBS ${MPI_Fortran_LIBRARIES})
  include_directories(${MPI_INCLUDE_PATH})
  list(GET MPI_Fortran_INCLUDE_PATH 0 ENV_MPI_ROOT)
  get_filename_component(temp "${ENV_MPI_ROOT}" NAME)
  if (temp STREQUAL "include" OR temp STREQUAL "lib")
    get_filename_component(ENV_MPI_ROOT "${ENV_MPI_ROOT}" DIRECTORY)
  endif ()
  get_filename_component(ENV_MPI_ROOT "${ENV_MPI_ROOT}" REALPATH)
  add_definitions(-DENV_MPI_ROOT="${ENV_MPI_ROOT}")
else ()
  add_definitions(-DVERS="6")
endif ()

# Get list of boolean compiler definitions set to ON
get_directory_property(COMPDEFS_TMP COMPILE_DEFINITIONS)
set(COMPDEFS)
foreach (definition IN LISTS COMPDEFS_TMP)
  if (${definition} MATCHES ".*=ON")
    list(APPEND COMPDEFS ${definition})
  endif ()
endforeach ()
list(REMOVE_DUPLICATES COMPDEFS)
list(SORT COMPDEFS)
string(REPLACE "=ON" " " COMPDEFS ${COMPDEFS})
string(STRIP "${COMPDEFS}" COMPDEFS)
separate_arguments(COMPDEFS)
list(LENGTH COMPDEFS NUM_COMPDEFS)
# Choose a number that will be greater than the number of definitions
# but not too much greater, as there will be a number of blank lines
# equal to the difference. Currently the most that can appear is 17.
foreach (i RANGE 20)
  if (i LESS NUM_COMPDEFS)
    list(GET COMPDEFS ${i} COMPDEF_CURRENT)
    add_definitions(-DCOMPDEF_${i}="${COMPDEF_CURRENT}")
  else ()
    add_definitions(-DCOMPDEF_${i}="")
  endif ()
endforeach ()

# Executable
if (MPI_BUILD)
  set(MCNP_EXEC "mcnp${MCNP_VERSION}.mpi")
  set(MCNP_EXEC_SYM "mcnp6.mpi")
else ()
  set(MCNP_EXEC "mcnp${MCNP_VERSION}")
  set(MCNP_EXEC_SYM "mcnp6")
endif ()

get_directory_property(COMPDEFS COMPILE_DEFINITIONS)
message(STATUS "MCNP611 C_FLAGS: ${CMAKE_C_FLAGS}")
message(STATUS "MCNP611 CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message(STATUS "MCNP611 Fortran_FLAGS: ${CMAKE_Fortran_FLAGS}")
message(STATUS "MCNP611 compile definitions: ${COMPDEFS}")

# Install
mcnp_install_exe(${MCNP_EXEC})
set_target_properties(${MCNP_EXEC} PROPERTIES LINKER_LANGUAGE Fortran)
mcnp_symlink_exe(${MCNP_EXEC} ${MCNP_EXEC_SYM})
