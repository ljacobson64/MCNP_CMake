#!/bin/bash

versions="514 515 516 X27 602 610 611 620"
for version in ${versions}; do
  if [ ${version} == "X27" ]; then patch=mcnpx27.patch
  else patch=mcnp${version}.patch
  fi
  if [ -d MCNP${version}/Source ]; then
    patch -p0 < patch/${patch}
  fi
done
