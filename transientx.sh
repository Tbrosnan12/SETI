#!/bin/bash

usage() {
    echo "Usage: $0"

    echo "If data has already been generated and you want to just re-make plots:"
    echo "Usage: $0 plot"
    exit 1
}

model=transientx

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
if [ "$#" == 1 ] && [ $1 == "plot" ]; then
    echo "remaking plot"
else 
   if [ -d "${model}_output" ]; then
       rm -r ${model}_output
   echo "deleted previous ${model} test data"
   fi

   declare -A matrix
   declare -A boxcar_matrix
   mkdir ${model}_output
   touch ${model}_output/${model}.txt
   touch ${model}_output/${model}_boxcar.txt

   for file in *.fil; do

      DM=$(echo "$file" | grep -oP '(?<=dm)[0-9]+(\.[0-9]+)?')
      width=$(echo "$file" | grep -oP '(?<=width)[0-9]+(\.[0-9]+)?')


      mkdir "${model}_output/${file}.${model}"  
      cd ${model}_output/${file}.${model}                                        #dedispersing and searching 
      transientx_fil -v -f ../../${file} --dms ${DM} --ddm 0 --ndm 1 --thre 7 --saveimage --maxw 0.07 --iqr | grep "nothing"


      echo "searching $file"


      dm_index=$(python3 -c "print(round(($DM - $DM_start) / $DM_step))")
      width_index=$(python3 -c "print(round(($width - $width_start) / $width_step))")
      #echo "dm_index=$dm_index"
      #echo "width_index=$width_index"

      candfile=$(ls *.cands 2>/dev/null | head -n 1)
      
      if [ -z "$candfile" ]; then
          #echo "candfile=$candfile"
          echo "no result pulse for ${file}"
          SNR=0
      else  
         read SNR boxcar < <(awk '
          # Initialize max values for the first data row
          NR == 1 {
             max = $6
             maxb = $5
             next
          }

          # Compare subsequent values in the sixth column to find the maximum
          NR > 1 && $6 > max {
             max = $6
             maxb = $5
          }

          # Print the final max and corresponding maxb values
          END { print max, maxb }
          ' "$candfile")
      fi
      
      if [ -z "$SNR" ]; then
         matrix[$width_index,$dm_index]=0
      else
         matrix[$width_index,$dm_index]=$SNR
      fi
      if [ -z "$boxcar" ]; then
         boxcar_matrix[$width_index,$dm_index]=0
      else
         boxcar_matrix[$width_index,$dm_index]=$boxcar
      fi
      cd ..
      cd ..
   done

   dm_range=$(python3 -c "print(int(($DM_end - $DM_start) / $DM_step))")
   width_range=$(python3 -c "print(int(($width_end - $width_start) / $width_step))")
   #echo "dm_range=$dm_range"
   #echo "width_range=$width_range"
   for i in $(seq 0 1 $dm_range); do
      row=""
      row2=""
      for j in $(seq 0 1 $width_range); do
         row+=" ${matrix[$j,$i]}"
         row2+=" ${boxcar_matrix[$j,$i]}"
      done
      echo "$row" >> "${model}_output/${model}.txt"
      echo "$row2" >> "${model}_output/boxcar.txt"
   done
fi


python3 ../graph.py injected_snr.txt ${model}_output/${model}.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step ${model}
python3 ../python/boxcar.py ${model}_output/boxcar.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step