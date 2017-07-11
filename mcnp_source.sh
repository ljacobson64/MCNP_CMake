#!/bin/bash

rm -rf */Source */Source_orig
tar -xzvf ${dist_dir}/mcnp/mcnp5.1.60_source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnpx_2.7.0_source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp6.1_source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp6.1.1beta_source.tar.gz
cp -r MCNP5/Source MCNP5/Source_orig
cp -r MCNPX/Source MCNPX/Source_orig
cp -r MCNP6/Source MCNP6/Source_orig
cp -r MCNP611/Source MCNP611/Source_orig
patch -p0 < patch/mcnp.5.1.60.patch
patch -p0 < patch/mcnp.x.2.7.0.patch
patch -p0 < patch/mcnp.6.1.patch
patch -p0 < patch/mcnp.6.1.1beta.patch
