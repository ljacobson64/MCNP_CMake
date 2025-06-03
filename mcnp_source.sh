#!/bin/bash

set -e

rm -rf */Source */Source_orig

tar -xzvf ${dist_dir}/mcnp514-source.tar.gz
tar -xzvf ${dist_dir}/mcnp515-source.tar.gz
tar -xzvf ${dist_dir}/mcnp516-source.tar.gz
tar -xzvf ${dist_dir}/mcnpx27-source.tar.gz
tar -xzvf ${dist_dir}/mcnp602-source.tar.gz
tar -xzvf ${dist_dir}/mcnp610-source.tar.gz
tar -xzvf ${dist_dir}/mcnp611-source.tar.gz
tar -xzvf ${dist_dir}/mcnp620-source.tar.gz

cp -r MCNP514/Source MCNP514/Source_orig
cp -r MCNP515/Source MCNP515/Source_orig
cp -r MCNP516/Source MCNP516/Source_orig
cp -r MCNPX27/Source MCNPX27/Source_orig
cp -r MCNP602/Source MCNP602/Source_orig
cp -r MCNP610/Source MCNP610/Source_orig
cp -r MCNP611/Source MCNP611/Source_orig
cp -r MCNP620/Source MCNP620/Source_orig

./patch.sh
