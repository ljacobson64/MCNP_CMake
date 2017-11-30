#!/bin/bash

rm -rf */Source */Source_orig
tar -xzvf ${dist_dir}/mcnp/mcnp516-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnpx27-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp610-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp611-source.tar.gz
cp -r MCNP516/Source MCNP516/Source_orig
cp -r MCNPX27/Source MCNPX27/Source_orig
cp -r MCNP610/Source MCNP610/Source_orig
cp -r MCNP611/Source MCNP611/Source_orig
patch -p0 < patch/mcnp516.patch
patch -p0 < patch/mcnpx27.patch
patch -p0 < patch/mcnp610.patch
patch -p0 < patch/mcnp611.patch
