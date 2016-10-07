#!/bin/bash

mkdir -p patch

rm -f temp
diff -rN "--unified=0" MCNP_CODE/MCNP5/Source MCNP_CODE/MCNP5/Source_new > temp
sed -e "s/.F90\t.*/.F90/" temp > patch/mcnp.patch.5.1.60
rm -f temp
diff -rN "--unified=0" MCNP_CODE/MCNP6/Source MCNP_CODE/MCNP6/Source_new > temp
sed -e "s/.F90\t.*/.F90/" temp > patch/mcnp.patch.6.1
rm -f temp
diff -rN "--unified=0" MCNP_CODE/MCNP611/Source MCNP_CODE/MCNP611/Source_new > temp
sed -e "s/.F90\t.*/.F90/" temp > patch/mcnp.patch.6.1.1
rm -f temp
