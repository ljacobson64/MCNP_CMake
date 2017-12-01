macro (mcnp_setup_build)
  message("")

  # Default to a release build
  if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "CMAKE_BUILD_TYPE not specified, defaulting to Release")
    set(CMAKE_BUILD_TYPE Release)
  endif ()
  if (NOT CMAKE_BUILD_TYPE STREQUAL "Release" AND
      NOT CMAKE_BUILD_TYPE STREQUAL "Debug" AND
      NOT CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    message(FATAL_ERROR "Specified CMAKE_BUILD_TYPE is invalid; valid options are Release, Debug, RelWithDebInfo")
  endif ()
  string(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_UPPER)
  message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

  # Installation directories
  set(INSTALL_BIN_DIR     bin)
  set(INSTALL_LIB_DIR     lib)
  set(INSTALL_INCLUDE_DIR include)
  set(INSTALL_TESTS_DIR   tests)
  set(INSTALL_TOOLS_DIR   tools)
  set(INSTALL_SHARE_DIR   share)

  # Get some environment variables
  set(ENV_USER "$ENV{USER}")
  execute_process(COMMAND hostname       OUTPUT_VARIABLE ENV_HOST OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND uname -s       OUTPUT_VARIABLE ENV_OS   OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND date +%m/%d/%y OUTPUT_VARIABLE ENV_DATE OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND date +%H:%M:%S OUTPUT_VARIABLE ENV_TIME OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro ()

macro (mcnp_setup_options)
  message("")

  option(BUILD_MCNP514    "Build MCNP514"               OFF)
  option(BUILD_MCNP515    "Build MCNP515"               OFF)
  option(BUILD_MCNP516    "Build MCNP516"               OFF)
  option(BUILD_MCNPX27    "Build MCNPX27"               OFF)
  option(BUILD_MCNP610    "Build MCNP610"               OFF)
  option(BUILD_MCNP611    "Build MCNP611"               OFF)

  option(MCNP_PLOT        "Build with plotting support" OFF)
  option(MPI_BUILD        "Build with MPI support"      OFF)
  option(OPENMP_BUILD     "Build with OpenMP support"   OFF)

  option(BUILD_STATIC_EXE "Build static executables"    OFF)

  if (BUILD_ALL)
    set(BUILD_MCNP5   ON)
    set(BUILD_MCNPX   ON)
    set(BUILD_MCNP6   ON)
    set(BUILD_MCNP611 ON)
  endif ()
endmacro ()

macro (mcnp_setup_flags)
  message("")

  #set(CMAKE_POSITION_INDEPENDENT_CODE ON)

  set(CXX_LIBRARY)
  foreach (library IN LISTS CMAKE_CXX_IMPLICIT_LINK_LIBRARIES)
    if (library MATCHES "c\\+\\+")
      set(CXX_LIBRARY ${library})
      break()
    endif ()
  endforeach ()

  set(CMAKE_C_IMPLICIT_LINK_LIBRARIES         "")
  set(CMAKE_C_IMPLICIT_LINK_DIRECTORIES       "")
  set(CMAKE_CXX_IMPLICIT_LINK_LIBRARIES       "${CXX_LIBRARY}")
  set(CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES     "")
  set(CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES   "")
  set(CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES "")

  if (BUILD_STATIC_EXE)
    message(STATUS "Building static executables")
    set(BUILD_SHARED_EXE OFF)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
    set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)
    set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS)
    set(CMAKE_SHARED_LIBRARY_LINK_Fortran_FLAGS)
    set(CMAKE_EXE_LINK_DYNAMIC_C_FLAGS)
    set(CMAKE_EXE_LINK_DYNAMIC_CXX_FLAGS)
    set(CMAKE_EXE_LINK_DYNAMIC_Fortran_FLAGS)
  else ()
    message(STATUS "Building shared executables")
    set(BUILD_SHARED_EXE ON)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".so")
  endif ()

  set(CMAKE_C_FLAGS_RELEASE              "-O1"   )
  set(CMAKE_C_FLAGS_RELWITHDEBINFO       "-O1 -g")
  set(CMAKE_CXX_FLAGS_RELEASE            "-O1"   )
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO     "-O1 -g")
  set(CMAKE_Fortran_FLAGS_RELEASE        "-O1"   )
  set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-O1 -g")

  message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
  message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
  message(STATUS "CMAKE_Fortran_FLAGS: ${CMAKE_Fortran_FLAGS}")
  message(STATUS "CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE_UPPER}: ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}")
  message(STATUS "CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE_UPPER}: ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}")
  message(STATUS "CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER}: ${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}")
  message(STATUS "CMAKE_C_IMPLICIT_LINK_LIBRARIES: ${CMAKE_C_IMPLICIT_LINK_LIBRARIES}")
  message(STATUS "CMAKE_CXX_IMPLICIT_LINK_LIBRARIES: ${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES}")
  message(STATUS "CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES: ${CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES}")
  message(STATUS "CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}")
endmacro ()

macro (mcnp_setup_rpath)
  message("")

  # Attempt to find CXX library path
  get_filename_component(CXX_COMPILER_ROOT ${CMAKE_CXX_COMPILER} DIRECTORY)
  get_filename_component(CXX_COMPILER_ROOT ${CXX_COMPILER_ROOT} DIRECTORY)
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
    get_filename_component(CXX_COMPILER_ROOT ${CXX_COMPILER_ROOT} DIRECTORY)
    find_path(CXX_LIBRARY_PATH
      NAMES "libimf.so"
      HINTS ${CXX_COMPILER_ROOT}
      PATH_SUFFIXES compiler/lib/intel64
    )
  else ()
    find_path(CXX_LIBRARY_PATH
      NAMES "libstdc++.so"
      HINTS ${CXX_COMPILER_ROOT}
      PATH_SUFFIXES lib64 lib32 lib
    )
  endif ()
  if (CXX_LIBRARY_PATH)
    get_filename_component(CXX_LIBRARY_PATH ${CXX_LIBRARY_PATH} ABSOLUTE)
  endif ()

  # Attempt to find Fortran library path
  get_filename_component(Fortran_COMPILER_ROOT ${CMAKE_Fortran_COMPILER} DIRECTORY)
  get_filename_component(Fortran_COMPILER_ROOT ${Fortran_COMPILER_ROOT} DIRECTORY)
  if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    get_filename_component(Fortran_COMPILER_ROOT ${Fortran_COMPILER_ROOT} DIRECTORY)
    find_path(Fortran_LIBRARY_PATH
      NAMES "libimf.so"
      HINTS ${Fortran_COMPILER_ROOT}
      PATH_SUFFIXES compiler/lib/intel64
    )
  else ()
    find_path(Fortran_LIBRARY_PATH
      NAMES "libgfortran.so"
      HINTS ${Fortran_COMPILER_ROOT}
      PATH_SUFFIXES lib64 lib32 lib
    )
  endif ()
  if (Fortran_LIBRARY_PATH)
    get_filename_component(Fortran_LIBRARY_PATH ${Fortran_LIBRARY_PATH} ABSOLUTE)
  endif ()

  set(INSTALL_RPATH_DIRS "${CMAKE_INSTALL_PREFIX}/${INSTALL_LIB_DIR}")

  if (CXX_LIBRARY_PATH)
    set(INSTALL_RPATH_DIRS "${INSTALL_RPATH_DIRS}:${CXX_LIBRARY_PATH}")
  endif ()
  if (Fortran_LIBRARY_PATH AND (NOT Fortran_LIBRARY_PATH STREQUAL CXX_LIBRARY_PATH))
    set(INSTALL_RPATH_DIRS "${INSTALL_RPATH_DIRS}:${Fortran_LIBRARY_PATH}")
  endif ()

  message(STATUS "INSTALL_RPATH_DIRS: ${INSTALL_RPATH_DIRS}")
endmacro ()

# Install an executable
macro (mcnp_install_exe exe_name)
  message(STATUS "Building executable: ${exe_name}")

  add_executable(${exe_name} ${SRC_FILES})
  if (BUILD_STATIC_EXE)
    set_target_properties(${exe_name}
      PROPERTIES INSTALL_RPATH ""
                 INSTALL_RPATH_USE_LINK_PATH FALSE)
    target_link_libraries(${exe_name} ${LINK_LIBS})
  else ()
    set_target_properties(${exe_name}
      PROPERTIES INSTALL_RPATH "${INSTALL_RPATH_DIRS}"
                 INSTALL_RPATH_USE_LINK_PATH TRUE)
    target_link_libraries(${exe_name} ${LINK_LIBS})
  endif ()
  install(TARGETS ${exe_name} DESTINATION ${INSTALL_BIN_DIR})
endmacro ()

macro(mcnp_symlink_exe exe_name exe_sym_name)
  install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${exe_name} ${exe_sym_name} \
                                WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${INSTALL_BIN_DIR})")
endmacro()
