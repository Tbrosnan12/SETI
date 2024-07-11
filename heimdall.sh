#!/bin/bash

cd output_files

DM_start=$(awk 'NR == 1 { print $1 }' ranges.txt)
DM_end=$(awk 'NR == 2 { print $1 }' ranges.txt)
DM_step=$(awk 'NR == 3 { print $1 }' ranges.txt)
width_start=$(awk 'NR == 4 { print $1 }' ranges.txt)
width_end=$(awk 'NR == 5 { print $1 }' ranges.txt)
width_step=$(awk 'NR == 6 { print $1 }' ranges.txt)

declare -A matrix
touch heimdall.txt


for file in *.fil; do
   mkdir "${file}.cands"
   heimdall -f ${file} -dm 0 2500 -dm_tol 1.01 -cand_sep_filter 1 -boxcar_max 32 -baseline_length 20 -output_dir ${file}.cands -rfi_no_broad;
   cd ${file}.cands

   DM=$(echo "$file" | grep -oP '(?<=dm)[0-9]+')
   width=$(echo "$file" | grep -oP '(?<=width)[0-9]+')
   echo "dm=$DM,width=$width"
   dm_index=$(echo " ($DM - $DM_start) / $DM_step "| bc)
   width_index=$( echo "($width - $width_start) / $width_step " | bc)
   echo "dm_index=$dm_index, width_index=$width_index"
   candfile=$( ls | head -n 1 )
   SNR=$(awk '
   # Print the First column (SNR values)
   { print $1; exit }
   ' "$candfile")
   #echo "$SNR"

   if [ -z "$SNR" ]; then
      matrix[$width_index,$dm_index]=0
   else
      matrix[$width_index,$dm_index]=$SNR
   fi
   cd ..
done

dm_range=$(echo " ($DM_end - $DM_start) / $DM_step "| bc)
width_range=$( echo "($width_end - $width_start) / $width_step " | bc)
for i in $(seq 0 1 $dm_range); do
   row=""
   for j in $(seq 0 1 $width_range); do
       row+=" ${matrix[$j,$i]}"
   done
   echo "$row" >> "heimdall.txt"
done

