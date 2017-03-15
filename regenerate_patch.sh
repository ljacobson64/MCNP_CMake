#!/bin/bash

mkdir -p patch
rm -f temp

folders=( MCNP5 MCNP6 MCNP611 )
versions=( 5.1.60 6.1 6.1.1beta )

for i in $(seq 0 2); do
  folder=${folders[$i]}
  version=${versions[$i]}
  mv MCNP_CODE/${folder}/Source      MCNP_CODE/${folder}/Source_new
  mv MCNP_CODE/${folder}/Source_orig MCNP_CODE/${folder}/Source
  diff -rN "--unified=0" MCNP_CODE/${folder}/Source MCNP_CODE/${folder}/Source_new > temp
  mv MCNP_CODE/${folder}/Source      MCNP_CODE/${folder}/Source_orig
  mv MCNP_CODE/${folder}/Source_new  MCNP_CODE/${folder}/Source
  sed -e "s/.F90\t.*/.F90/" -e "s/.inc\t.*/.inc/" temp > patch/mcnp.${version}.patch
  rm -f temp
done
