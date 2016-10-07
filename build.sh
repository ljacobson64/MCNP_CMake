#!/bin/bash

jobs=8
intel=true

if [ "$intel" = true ]; then
  #source /opt/intel/composer_xe_2011_sp1.13.367/bin/compilervars.sh intel64               # 12.1.0
  #source /opt/intel/composer_xe_2013.5.192/bin/compilervars.sh intel64                    # 13.1.0
  #source /opt/intel/composer_xe_2013_sp1.6.214/bin/compilervars.sh intel64                # 14.0.4
  #source /opt/intel/composer_xe_2015.6.233/bin/compilervars.sh intel64                    # 15.0.6
  #source /opt/intel/compilers_and_libraries_2016.4.258/linux/bin/compilervars.sh intel64  # 16.0.4
  source /opt/intel/compilers_and_libraries_2017.0.098/linux/bin/compilervars.sh intel64  # 17.0.0
  CC=`which icc`
  CXX=`which icpc`
  FC=`which ifort`
else
  CC=/usr/bin/gcc
  CXX=/usr/bin/g++
  FC=/usr/bin/gfortran
fi

cmake_string=
cmake_string+=" "-DBUILD_MCNP5=ON
cmake_string+=" "-DBUILD_MCNP6=ON
cmake_string+=" "-DBUILD_MCNP611=ON
cmake_string+=" "-DMCNP_PLOT=ON
cmake_string+=" "-DOPENMP_BUILD=ON
cmake_string+=" "-DMPI_BUILD=ON
#cmake_string+=" "-DSTATIC_LIB=ON
cmake_string+=" "-DCMAKE_C_COMPILER=${CC}
cmake_string+=" "-DCMAKE_CXX_COMPILER=${CXX}
cmake_string+=" "-DCMAKE_Fortran_COMPILER=${FC}
cmake_string+=" "-DCMAKE_INSTALL_PREFIX=/home/lucas/MCNP_CMake

rm -rf bin
rm -rf bld
mkdir bld
cd bld
cmake ../src $cmake_string
make -j ${jobs}
make install
cd ..

rm -f out? runtp?
./bin/mcnp5.mpi tasks ${jobs}
grep -A1 thread outp
rm -f out? runtp?
./bin/mcnp6.mpi tasks ${jobs}
grep -A1 thread outp
rm -f out? runtp?
./bin/mcnp611.mpi tasks ${jobs}
grep -A1 thread outp
rm -f out? runtp?
