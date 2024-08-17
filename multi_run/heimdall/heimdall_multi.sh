#!/bin/bash

model=heimdall

# Change these values to your liking before running this script
DM_start=0
DM_end=100
DM_step=100
width_start=1
width_end=1
width_step=1

cpu_core_start=0
cpu_core_end=2 

# Clean up previous iteration data if any exists
if ls iter* 1> /dev/null 2>&1; then
    rm -r iter*
    echo "Removed previous data"
fi

# Start parallel processes for each CPU core
for val in $(seq $cpu_core_start $cpu_core_end); do
    csh heimdall/heimdall_sched.sh $DM_start $DM_end $DM_step $width_start $width_end $width_step $val $model &
done


wait
n=$(ls -d iter* 2>/dev/null | wc -l)
count=1

# Process output from each iteration directory
for val in $(seq $cpu_core_start $cpu_core_end); do 
    iter_dir="iter${val}"
    
    if [ -d "$iter_dir" ]; then
        cd "$iter_dir"
        echo -ne "searching iteration $count / $n\r"
        count=$(($count+1))

        # Run heimdall.sh and process output
        bash heimdall.sh | grep nothing
        
        cd output_files
        cp injected_snr.txt ../
        if [ -f "boxcar.png" ]; then
            cp boxcar.png ../
        fi
        cp "${model}_output/${model}.txt" ../
        cd ..
        
        # Clean up the output files
        #rm -r output_files
        rm -f *.py *.sh
        rm -r python
        
        cd ..
    else
        echo "Directory $iter_dir does not exist"
    fi
done

# Run the refine script at the end
bash heimdall/refine_heimdall.sh $model
