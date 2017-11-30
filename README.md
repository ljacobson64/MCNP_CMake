These files allow for users to build
MCNP516, MCNPX27, MCNP610, and MCNP611
with CMake.

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
cmake ../src -DBUILD_MCNP516=ON \
             -DBUILD_MCNPX27=ON \
             -DBUILD_MCNP610=ON \
             -DBUILD_MCNP611=ON \
             -DMCNP_PLOT=ON \
             -DOPENMP_BUILD=ON \
             -DMPI_BUILD=ON \
             -DCMAKE_INSTALL_PREFIX=${install_prefix}
```

The MCNP tarballs should be named like this:

```
${dist_dir}/mcnp/mcnp516-source.tar.gz
${dist_dir}/mcnp/mcnpx27-source.tar.gz
${dist_dir}/mcnp/mcnp610-source.tar.gz
${dist_dir}/mcnp/mcnp611-source.tar.gz
```
