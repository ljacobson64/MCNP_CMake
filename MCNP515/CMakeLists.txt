message("")

set(LINK_LIBS)

# Source files
file(GLOB SRC_FILES
  "Source/src/*.c"
  "Source/src/*.cpp"
  "Source/src/*.F90"
)

set(MCNP_VERSION 515)
if ("/${SRC_FILES};" MATCHES "/main.F90;")
  message(STATUS "MCNP${MCNP_VERSION} source files found")
else ()
  message(FATAL_ERROR "MCNP${MCNP_VERSION} source files not found in MCNP${MCNP_VERSION}/Source")
endif ()

# C compiler flags
if (INTEL_C)
  #set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcmodel=medium")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pc64")
else ()
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
endif ()

# Fortran compiler flags
if (INTEL_FORTRAN)
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -no-vec")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -heap-arrays 1024")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -traceback")
  #set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -mcmodel=medium")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -pc64")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -r8")
else ()
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -m64")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -mieee-fp")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdollar-ok")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-sign-zero")
  if (BUILD_PLOT)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-real-8")
  endif ()
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fallow-argument-mismatch")
endif ()

# Preprocessor directives
add_definitions(-DKODE="mcnp")
add_definitions(-DTHREAD="MCNP5_RSICC")
add_definitions(-DTVERS="1.51")
add_definitions(-DLODDAT="${ENV_DATE}")
add_definitions(-DLINUX=ON)
add_definitions(-DUNIX=ON)
if (INTEL_FORTRAN)
  add_definitions(-DINTEL=ON)
  add_definitions(-DDIRACCESS_RECL_WORDS=ON)
else ()
  add_definitions(-DGFORTRAN=ON)
endif ()
add_definitions(-DF90_INT_4BYTE=ON)
add_definitions(-DF90_REAL_8BYTE=ON)

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
  add_definitions(-DMCPLOT=ON)
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
  file(GLOB SRC_FILES ${SRC_FILES} "Source/dotcomm/src/*.F90")
  file(GLOB SRC_FILES ${SRC_FILES} "Source/dotcomm/src/internals/mpi/*.c")
  add_definitions(-DVERS="5.mpi")
  add_definitions(-DMULTP=ON)
  add_definitions(-DMPI=ON)
  add_definitions(-DDMMP_NAME="mcnp5.mpi")
  add_definitions(-D_DOTCOMM_MPI=ON)
  list(APPEND LINK_LIBS ${MPI_Fortran_LIBRARIES})
  include_directories(${MPI_INCLUDE_PATH})
  include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/dotcomm/include)
  include_directories(${CMAKE_CURRENT_LIST_DIR}/Source/dotcomm/src/internals/mpi)
else ()
  add_definitions(-DVERS="5")
endif ()

# Executable
if (BUILD_MPI)
  set(MCNP_EXEC "mcnp${MCNP_VERSION}.mpi")
  set(MCNP_EXEC_SYM "mcnp5.mpi")
else ()
  set(MCNP_EXEC "mcnp${MCNP_VERSION}")
  set(MCNP_EXEC_SYM "mcnp5")
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
if (NOT BUILD_MCNP516)
  mcnp_symlink_exe(${MCNP_EXEC} ${MCNP_EXEC_SYM})
endif ()
