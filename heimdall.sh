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
   if [ -d "heimdall_output" ]; then
       rm -r heimdall_output
   echo "deleted previous heimdall test data"
   fi

   declare -A matrix
   mkdir heimdall_output
   touch heimdall_output/heimdall.txt

   for file in *.fil; do
      mkdir "heimdall_output/${file}.cands"                                               #dedispersing and searching 
      heimdall -f ${file} -dm 0 2500 -dm_tol 1.01 -cand_sep_filter 1 -boxcar_max 32 -baseline_length 20 -output_dir heimdall_output/${file}.cands -rfi_no_broad;
      cd heimdall_output/${file}.cands

      echo "searching $file"

      DM=$(echo "$file" | grep -oP '(?<=dm)[0-9]+(\.[0-9]+)?')
      width=$(echo "$file" | grep -oP '(?<=width)[0-9]+(\.[0-9]+)?')


      dm_index=$(python3 -c "print(round(($DM - $DM_start) / $DM_step))")
      width_index=$(python3 -c "print(round(($width - $width_start) / $width_step))")
      #echo "dm_index=$dm_index"
      #echo "width_index=$width_index"

      candfile=$( ls | head -n 1 )

      if [ -z "$candfile" ]; then
          echo "candfile=$candfile"
          echo "no result pulse for ${file}"
          SNR=0
      else 
         SNR=$(awk '
         # Store the maximum value of the first column
         NR == 1 {
         max = $1
         next
         }

         NR > 1 && $1 > max {
         max = $1
         }
         END { print max }
         ' "$candfile")
         #echo "$SNR"
      fi
      
      if [ -z "$SNR" ]; then
         matrix[$width_index,$dm_index]=0
      else
         matrix[$width_index,$dm_index]=$SNR
      fi
      cd ..
      cd ..
   done

   dm_range=$(python3 -c "print(int(($DM_end - $DM_start) / $DM_step))")
   width_range=$(python3 -c "print(int(($width_end - $width_start) / $width_step))")
   for i in $(seq 0 1 $dm_range); do
      row=""
      for j in $(seq 0 1 $width_range); do
         row+=" ${matrix[$j,$i]}"
      done
      echo "$row" >> "heimdall_output/heimdall.txtheimdall.txt"
   done
fi


python3 ../graph.py injected_snr.txt heimdall_output/heimdall.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step heimdall