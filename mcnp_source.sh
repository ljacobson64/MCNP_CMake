#!/bin/bash

rm -rf */Source */Source_orig
tar -xzvf ${dist_dir}/mcnp/mcnp514-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp515-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp516-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnpx27-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp602-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp610-source.tar.gz
tar -xzvf ${dist_dir}/mcnp/mcnp611-source.tar.gz
cp -r MCNP514/Source MCNP514/Source_orig
cp -r MCNP515/Source MCNP515/Source_orig
cp -r MCNP516/Source MCNP516/Source_orig
cp -r MCNPX27/Source MCNPX27/Source_orig
cp -r MCNP602/Source MCNP602/Source_orig
cp -r MCNP610/Source MCNP610/Source_orig
cp -r MCNP611/Source MCNP611/Source_orig
./patch.sh
