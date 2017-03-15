#!/bin/bash

set -e

clear
clear

jobs=8

compiler=gcc-6
#compiler=intel-17

openmpi_version=1.10.5

orig_dir=${PWD}
install_dir=${HOME}/opt/${compiler}
build_dir=${orig_dir}/bld
install_prefix=${orig_dir}

if [[ ${compiler} == "intel"* ]]; then
  if   [[ ${compiler} == "intel-12" ]]; then intel_root=/opt/intel/composer_xe_2011_sp1.13.367
  elif [[ ${compiler} == "intel-13" ]]; then intel_root=/opt/intel/composer_xe_2013.5.192
  elif [[ ${compiler} == "intel-14" ]]; then intel_root=/opt/intel/composer_xe_2013_sp1.6.214
  elif [[ ${compiler} == "intel-15" ]]; then intel_root=/opt/intel/composer_xe_2015.6.233
  elif [[ ${compiler} == "intel-16" ]]; then intel_root=/opt/intel/compilers_and_libraries_2016.4.258/linux
  elif [[ ${compiler} == "intel-17" ]]; then intel_root=/opt/intel/compilers_and_libraries_2017.0.098/linux
  fi

  export PATH=${intel_root}/bin/intel64:${PATH}
  export LD_LIBRARY_PATH=${intel_root}/compiler/lib/intel64:${LD_LIBRARY_PATH}

  CC=`which icc`
  CXX=`which icpc`
  FC=`which ifort`
elif [[ ${compiler} == "gcc"* ]]; then
  CC=`which gcc`
  CXX=`which g++`
  FC=`which gfortran`
else
  exit
fi

mpi_root=${install_dir}/openmpi-${openmpi_version}

export PATH=${mpi_root}/bin:${PATH}
export LD_LIBRARY_PATH=${mpi_root}/lib:${LD_LIBRARY_PATH}

cmake_string=

cmake_string+=" "-DBUILD_MCNP5=ON
#cmake_string+=" "-DBUILD_MCNP6=ON
cmake_string+=" "-DBUILD_MCNP611=ON
#cmake_string+=" "-DBUILD_MCNPX=ON

cmake_string+=" "-DMCNP_PLOT=ON
cmake_string+=" "-DOPENMP_BUILD=ON
cmake_string+=" "-DMPI_BUILD=ON

#cmake_string+=" "-DSTATIC_LIB=ON

#cmake_string+=" "-DCMAKE_BUILD_TYPE=Debug
#cmake_string+=" "-DCMAKE_BUILD_TYPE=Release

cmake_string+=" "-DCMAKE_C_COMPILER=${CC}
cmake_string+=" "-DCMAKE_CXX_COMPILER=${CXX}
cmake_string+=" "-DCMAKE_Fortran_COMPILER=${FC}
cmake_string+=" "-DCMAKE_INSTALL_PREFIX=${install_prefix}

log_file=${orig_dir}/install_${compiler}.log

rm -rf ${build_dir}
rm -rf bin
mkdir -p ${build_dir}
cd ${build_dir}

which cmake
cmake --version

cmake ${orig_dir}/src ${cmake_string}
make -j ${jobs}
make install

#/usr/bin/time -v cmake ${orig_dir}/src ${cmake_string} 2>&1 | tee ${log_file}
#/usr/bin/time -v make -j ${jobs} VERBOSE=1 2>&1 | tee -a ${log_file}
#/usr/bin/time -v make install 2>&1 | tee -a ${log_file}

cd ..
