#!/bin/bash

mkdir -p patch
rm -f temp

versions="516 X27 602 610 611"

for version in ${versions}; do
  folder=MCNP${version}
  if [ ${version} == "X27" ]; then patch=mcnpx27.patch
  else patch=mcnp${version}.patch
  fi
  mv ${folder}/Source      ${folder}/Source_new
  mv ${folder}/Source_orig ${folder}/Source
  diff -rN "--unified=0" ${folder}/Source ${folder}/Source_new > temp
  mv ${folder}/Source      ${folder}/Source_orig
  mv ${folder}/Source_new  ${folder}/Source
  sed -e "s/.F\t.*/.F/" \
      -e "s/.F90\t.*/.F90/" \
      -e "s/.inc\t.*/.inc/" \
      temp > patch/${patch}
  rm -f temp
done
