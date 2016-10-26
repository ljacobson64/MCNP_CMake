#!/bin/bash

jobs=8
COMPILER=intel-17.0.0
MPI=openmpi-1.10.4
INTEL_ROOT=/opt/intel

if   [[ ${COMPILER} == "gcc"*   ]]; then COMP=gcc
elif [[ ${COMPILER} == "intel"* ]]; then COMP=intel
fi

if   [[ ${COMPILER} == intel-12.1.0 ]]; then INTEL_ROOT=${INTEL_ROOT}/composer_xe_2011_sp1.13.367
elif [[ ${COMPILER} == intel-13.1.0 ]]; then INTEL_ROOT=${INTEL_ROOT}/composer_xe_2013.5.192
elif [[ ${COMPILER} == intel-14.0.4 ]]; then INTEL_ROOT=${INTEL_ROOT}/composer_xe_2013_sp1.6.214
elif [[ ${COMPILER} == intel-15.0.6 ]]; then INTEL_ROOT=${INTEL_ROOT}/composer_xe_2015.6.233
elif [[ ${COMPILER} == intel-16.0.4 ]]; then INTEL_ROOT=${INTEL_ROOT}/compilers_and_libraries_2016.4.258
elif [[ ${COMPILER} == intel-17.0.0 ]]; then INTEL_ROOT=${INTEL_ROOT}/compilers_and_libraries_2017.0.098
fi

if   [[ ${COMP} == gcc   ]]; then MPI_ROOT=/home/lucas/opt-gcc/${MPI}
elif [[ ${COMP} == intel ]]; then MPI_ROOT=/home/lucas/opt-intel/${MPI}
fi

#source ${INTEL_ROOT}/linux/bin/compilervars.sh intel64

export            PATH=${INTEL_ROOT}/linux/bin/intel64:${PATH}
export LD_LIBRARY_PATH=${INTEL_ROOT}/linux/compiler/lib/intel64:${PATH}
export            PATH=${MPI_ROOT}/bin:${PATH}
export LD_LIBRARY_PATH=${MPI_ROOT}/lib:${LD_LIBRARY_PATH}

CC=/usr/bin/gcc
CXX=/usr/bin/g++
if [[ ${COMP} == gcc ]]; then
  #CC=/usr/bin/gcc
  #CXX=/usr/bin/g++
  FC=/usr/bin/gfortran
elif [[ ${COMP} == intel ]]; then
  #CC=`which icc`
  #CXX=`which icpc`
  FC=`which ifort`
fi

cmake_string=

cmake_string+=" "-DBUILD_MCNP5=ON
cmake_string+=" "-DBUILD_MCNP6=ON
cmake_string+=" "-DBUILD_MCNP611=ON
#cmake_string+=" "-DBUILD_MCNPX=ON

cmake_string+=" "-DMCNP_PLOT=ON
cmake_string+=" "-DOPENMP_BUILD=ON
cmake_string+=" "-DMPI_BUILD=ON

#cmake_string+=" "-DSTATIC_LIB=ON
#cmake_string+=" "-DCMAKE_BUILD_TYPE=Debug
cmake_string+=" "-DCMAKE_C_COMPILER=${CC}
cmake_string+=" "-DCMAKE_CXX_COMPILER=${CXX}
cmake_string+=" "-DCMAKE_Fortran_COMPILER=${FC}
cmake_string+=" "-DCMAKE_INSTALL_PREFIX=/home/lucas/MCNP_CMake

#rm -rf bin
rm -rf bld
mkdir bld
cd bld
cmake ../src $cmake_string
make -j ${jobs}
#make -j ${jobs} VERBOSE=1
make install
cd ..
