#!/bin/bash

usage() {
    echo "Usage: $0"

    echo "If data has already been generated and you want to just re-make plots:"
    echo "Usage: $0 plot"
    exit 1
}

if [ -d "output_files" ]; then 
   cd output_files
else 
   echo "Warning: need to generate filterbanks in /output_files first"
   usage                            
fi

DM_start=$(awk 'NR == 1 { print $1 }' ranges.txt)
DM_end=$(awk 'NR == 2 { print $1 }' ranges.txt)
DM_step=$(awk 'NR == 3 { print $1 }' ranges.txt)
width_start=$(awk 'NR == 4 { print $1 }' ranges.txt)
width_end=$(awk 'NR == 5 { print $1 }' ranges.txt)
width_step=$(awk 'NR == 6 { print $1 }' ranges.txt)


# Check if the correct number of arguments is provided
if [ "$#" == 1 ] && [ $1 =="plot" ]; then
    echo "remaking plot"
else 
   if [ -d "destroy_output" ]; then
      rm -r destroy_output
      echo "deleted previous destroy test data"
   fi

   declare -A matrix
   mkdir destroy_output
   touch destroy_output/destroy.txt

   for file in *.fil; do
      DM=$(echo "$file" | grep -oP '(?<=dm)[0-9]+(\.[0-9]+)?')
      width=$(echo "$file" | grep -oP '(?<=width)[0-9]+(\.[0-9]+)?')

      dedisperse ${file} -d ${DM} > destroy_output/test_single_dm${DM}_width${width}.fil.tim          # dedisperse 

      echo "searching $file"
      cd destroy_output
      ../../destroy_gutted/destroy test_single_dm${DM}_width${width}.fil.tim | grep "Destruction"        # searrch data 
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
fi

python3 ../graph.py injected_snr.txt destroy_output/destroy.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step destroy
