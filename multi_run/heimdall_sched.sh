#!/bin/bash

mkdir "iter$val"
cd "iter$val"
cp ../../*.py .
cp ../../*.sh .
cp -r ../../python .
cp ../refine* .

echo "starting iteration:${val}"
schedtool -a $val -e bash create.sh $DM_start $DM_end $DM_step $width_start $width_end $width_step
cd ..
