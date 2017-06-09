These files allow for users to build MCNP5, MCNP6, and MCNP611 with CMake.

Build example:

```
dist_dir=<location_of_mcnp_tarballs>
install_prefix=${PWD}
mkdir MCNP
cd MCNP
git clone https://github.com/ljacobson64/MCNP_CMake
cd MCNP_CMake
bash mcnp_source.sh
cd ..
ln -s MCNP_CMake src
mkdir bld
cd bld
cmake ../src -DBUILD_MCNP5=ON \
             -DBUILD_MCNP6=OFF \
             -DBUILD_MCNP611=ON \
             -DMCNP_PLOT=ON \
             -DOPENMP_BUILD=ON \
             -DMPI_BUILD=ON \
             -DCMAKE_INSTALL_PREFIX=${install_prefix}
```

The MCNP tarballs should be named like this:

```
${dist_dir}/mcnp/mcnp5.1.60_source.tar.gz
${dist_dir}/mcnp/mcnp6.1_source.tar.gz
${dist_dir}/mcnp/mcnp6.1.1beta_source.tar.gz
```
