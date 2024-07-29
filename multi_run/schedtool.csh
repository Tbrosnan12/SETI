#!/bin/csh


set DM_start = $1
set DM_end = $2            #change these values to your liking before runing this script by: bash multi_core.sh
set DM_step = $3
set width_start = $4
set width_end = $5
set width_step = $6
set val = $7
set model = $8

mkdir "iter$val"
cd "iter$val"
cp ../../*.py .
cp ../../*.sh .
cp ../../python .
    
schedtool -a $val -e bash create.sh $DM_start $DM_end $DM_step $width_start $width_end $width_step
schedtool -a $val -e bash ${model}.sh
cd ..