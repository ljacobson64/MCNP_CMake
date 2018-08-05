message("")

set(LINK_LIBS)

# Source files
file(GLOB SRC_FILES
  "Source/cgm/*.c"
  "Source/cgm/*.cpp"
  "Source/dedx/*.F90"
  "Source/hexs/*.F90"
  "Source/import/*.F90"
  "Source/incl_abla/*.F90"
  "Source/lcs/*.F90"
  "Source/llnlfiss/*.cpp"
  "Source/llnlfiss/*.F90"
  "Source/regl/*.F90"
  "Source/src/*.c"
  "Source/src/*.F90"
  "Source/src/partisn/*.F90"
  "Source/src/utils/*.c"
  "Source/src/utils/*.F90"
)

set(MCNP_VERSION 620)
if ("/${SRC_FILES};" MATCHES "/main.F90;")
  message(STATUS "MCNP${MCNP_VERSION} source files found")
else ()
  message(FATAL_ERROR "MCNP${MCNP_VERSION} source files not found in MCNP${MCNP_VERSION}/Source")
endif ()

# C compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
if (NOT CMAKE_C_COMPILER_ID STREQUAL "Intel")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-common")
endif ()

# CXX compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m64")
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-common")
endif ()

# Fortran compiler flags
if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -free")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -heap-arrays 1024")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -traceback")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -standard-semantics")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -m64")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -pc64")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -error-limit 1000")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -warn nodeclarations")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -diag-disable 8290,8291,8577")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -stand f03")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -r8")
else ()
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -m64")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -ffree-form")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -mieee-fp")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdollar-ok")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -std=f2003")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-real-8")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-double-8")
endif ()

# Include directories
####include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/import)
####include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/import/cgm)

# Preprocessor directives
add_definitions(-DKODE="mcnp")
add_definitions(-DTHREAD="MCNP_6.20")
add_definitions(-DTVERS="6.2.0")
add_definitions(-DLODDAT="${ENV_DATE}")
add_definitions(-DLINUX=ON)
add_definitions(-DUNIX=ON)
if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  add_definitions(-DINTEL=ON)
else ()
  add_definitions(-DGFORTRAN=ON)
endif ()
add_definitions(-DF90_INT_4BYTE=ON)
add_definitions(-DF90_REAL_8BYTE=ON)
add_definitions(-DCGM=ON)
add_definitions(-DCEM=ON)
add_definitions(-DCEM_M6=ON)
add_definitions(-DLAQGSM=ON)
add_definitions(-DUOD=ON)
add_definitions(-DFREYA=ON)
add_definitions(-DENV_USER="${ENV_USER}")
add_definitions(-DENV_HOST="${ENV_HOST}")
add_definitions(-DENV_OS="${ENV_OS}")
add_definitions(-DENV_DATE="${ENV_DATE}")
add_definitions(-DENV_TIME="${ENV_TIME}")
add_definitions(-DENV_CC="${CMAKE_C_COMPILER}")
add_definitions(-DENV_CXX="${CMAKE_CXX_COMPILER}")
add_definitions(-DENV_F90="${CMAKE_Fortran_COMPILER}")
execute_process(COMMAND bash "-c" "${CMAKE_C_COMPILER}       --version 2>&1 | head -1" OUTPUT_VARIABLE ENV_CC_VERS)
execute_process(COMMAND bash "-c" "${CMAKE_CXX_COMPILER}     --version 2>&1 | head -1" OUTPUT_VARIABLE ENV_CXX_VERS)
execute_process(COMMAND bash "-c" "${CMAKE_Fortran_COMPILER} --version 2>&1 | head -1" OUTPUT_VARIABLE ENV_F90_VERS)
string(REPLACE "\n" "" ENV_CC_VERS  ${ENV_CC_VERS})
string(REPLACE "\n" "" ENV_CXX_VERS ${ENV_CXX_VERS})
string(REPLACE "\n" "" ENV_F90_VERS ${ENV_F90_VERS})
add_definitions(-DENV_CC_VERS="${ENV_CC_VERS}")
add_definitions(-DENV_CXX_VERS="${ENV_CXX_VERS}")
add_definitions(-DENV_F90_VERS="${ENV_F90_VERS}")

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
if (BUILD_PLOT)
  find_package(X11 REQUIRED)
  add_definitions(-DPLOT=ON)
  add_definitions(-DXLIB=ON)
  list(APPEND LINK_LIBS ${X11_LIBRARIES})
  if (BUILD_STATIC_EXE)
    list(APPEND LINK_LIBS xcb pthread Xau Xdmcp)
  endif ()
endif ()

# OpenMP
if (BUILD_OPENMP)
  find_package(OpenMP REQUIRED)
  add_definitions(-DOMP=ON)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${OpenMP_Fortran_FLAGS}")
endif ()

# MPI
if (BUILD_MPI)
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
if (BUILD_MPI)
  set(MCNP_EXEC "mcnp${MCNP_VERSION}.mpi")
  set(MCNP_EXEC_SYM "mcnp6.mpi")
else ()
  set(MCNP_EXEC "mcnp${MCNP_VERSION}")
  set(MCNP_EXEC_SYM "mcnp6")
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
