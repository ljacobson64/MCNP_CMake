#!/bin/bash

cd MCNP_CODE
rm -rf */Source */Source_orig
tar -xzvf ${dist_dir}/mcnp/mcnp5.1.60_source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp6.1_source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp6.1.1beta_source.tar.gz
cp -r MCNP5/Source MCNP5/Source_orig
cp -r MCNP6/Source MCNP6/Source_orig
cp -r MCNP611/Source MCNP611/Source_orig
cd ..
patch -p0 < patch/mcnp.5.1.60.patch
patch -p0 < patch/mcnp.6.1.patch
patch -p0 < patch/mcnp.6.1.1beta.patch
