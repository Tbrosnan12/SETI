#!/bin/bash
N=$1

model=heimdall

DM_start=0
DM_end=2500                 #change these values to your liking before runing this script by: bash multi_core.sh
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

for val in $( seq $cpu_core_start 1 $cpu_core_end ); do
    csh heimdall_sched.sh $DM_start $DM_end $DM_step $width_start $width_end $width_step $val $model &
done 

wait

for iter in iter*; do 
    cd $iter
    bash ../../heimdall.sh 
    
    cd output_files
    mv injected_snr.txt ../
    if [ -f "boxcar.png" ]; then
        mv boxcar.png ../
    fi
    mv ${model}_output/${model}.txt ../
    cd ..
    rm -r output_files
    rm *py && rm *sh && rm -r python
    cd ..
done 

wait 

bash refine-2.sh $model