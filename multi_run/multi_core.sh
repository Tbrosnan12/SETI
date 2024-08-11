#!/bin/bash

#change these values to your liking before runing this script by: bash multi_core.sh

model=transientx

DM_start=0
DM_end=2500                 
DM_step=100
width_start=1
width_end=25
width_step=1

cpu_core_start=1
cpu_core_end=32 



if ls iter* 1> /dev/null 2>&1; then
  rm -r iter*
  echo "Removed previous data"
fi



for i in $(seq $cpu_core_start 1 $cpu_core_end); do
    csh schedtool.csh $DM_start $DM_end $DM_step $width_start $width_end $width_step $i $model &
done

# Wait for all background jobs to complete
wait

bash refine-2.sh