#!/bin/bash

cd output_files


DM_start=$(awk 'NR == 1 { print $1 }' ranges.txt)
DM_end=$(awk 'NR == 2 { print $1 }' ranges.txt)
DM_step=$(awk 'NR == 3 { print $1 }' ranges.txt)
width_start=$(awk 'NR == 4 { print $1 }' ranges.txt)
width_end=$(awk 'NR == 5 { print $1 }' ranges.txt)
width_step=$(awk 'NR == 6 { print $1 }' ranges.txt)

if [ -d "destroy_output" ]; then
   rm -r destroy_output
   echo "deleted previous destroy test data"
fi

declare -A matrix
mkdir destroy_output
touch destroy_output/destroy.txt

for file in *.fil; do
   DM=$(echo "$file" | grep -oP '(?<=dm)[0-9]+')
   width=$(echo "$file" | grep -oP '(?<=width)[0-9]+')
   dedisperse ${file} -d ${DM} > destroy_output/test_single_dm${DM}_width${width}.fil.tim

   echo "searching $file"
   cd destroy_output
   ../../destroy_gutted/destroy test_single_dm${DM}_width${width}.fil.tim | grep "Destruction"
   cd ..
   dm_index=$(echo " ($DM - $DM_start) / $DM_step "| bc)
   width_index=$( echo "($width - $width_start) / $width_step " | bc)

   candfile=destroy_output/pulses.pls
   SNR=$(awk '
   # Store the maximum value of the first column
   NR == 1 {
   max = $4
   next
   }

   NR > 1 && $4 > max {
   max = $4
   }
   END { print max }
   ' "$candfile")
   #echo "$SNR"

   if [ -z "$SNR" ]; then
      matrix[$width_index,$dm_index]=0
   else
      matrix[$width_index,$dm_index]=$SNR
   fi
done

dm_range=$(echo " ($DM_end - $DM_start) / $DM_step "| bc)
width_range=$( echo "($width_end - $width_start) / $width_step " | bc)
for i in $(seq 0 1 $dm_range); do
   row=""
   for j in $(seq 0 1 $width_range); do
       row+=" ${matrix[$j,$i]}"
   done
   echo "$row" >> "destroy_output/destroy.txt"
done

python ../graph.py injected_snr.txt destroy_output/destroy.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step destroy
