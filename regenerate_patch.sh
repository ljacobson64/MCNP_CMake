#!/bin/bash

mkdir -p patch
rm -f temp

folders=(  MCNP5  MCNPX   MCNP6 MCNP611   )
versions=( 5.1.60 x.2.7.0 6.1   6.1.1beta )

for i in $(seq 0 3); do
  folder=${folders[$i]}
  version=${versions[$i]}
  mv ${folder}/Source      ${folder}/Source_new
  mv ${folder}/Source_orig ${folder}/Source
  diff -rN "--unified=0" ${folder}/Source ${folder}/Source_new > temp
  mv ${folder}/Source      ${folder}/Source_orig
  mv ${folder}/Source_new  ${folder}/Source
  sed -e "s/.F\t.*/.F/" \
      -e "s/.F90\t.*/.F90/" \
      -e "s/.inc\t.*/.inc/" \
      temp > patch/mcnp.${version}.patch
  rm -f temp
done
