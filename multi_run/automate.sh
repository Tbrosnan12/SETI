#!/bin/bash

N=$1

for i in $(seq 1 1 $N ); do
    bash multi_core.sh
    wait
    mv out.txt out${i}.txt
    out_files="${out_files} out${i}.txt"
done

model=$(grep "model=" multi_core.sh | awk -F '=' '{print $2}')

dir=$(ls | grep iter |  head -n 1)

cd $dir
DM_start=$(awk 'NR == 1 { print $1 }' ranges.txt)
DM_end=$(awk 'NR == 2 { print $1 }' ranges.txt)
DM_step=$(awk 'NR == 3 { print $1 }' ranges.txt)
width_start=$(awk 'NR == 4 { print $1 }' ranges.txt)
width_end=$(awk 'NR == 5 { print $1 }' ranges.txt)
width_step=$(awk 'NR == 6 { print $1 }' ranges.txt)
cd ..

python3 graph_add.py $DM_start $DM_end $DM_step $width_start $width_end $width_step $model ${out_files}
