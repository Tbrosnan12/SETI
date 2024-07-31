#!/bin/bash

usage() {
    echo "Usage: $0"

    echo "If data has already been generated and you want to just re-make plots:"
    echo "Usage: $0 plot"
    exit 1
}

model=presto 

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
   touch ${model}_output/boxcar.txt
  
   for file in *.fil; do
      cd ${model}_output/   
      DM=$(echo "$file" | grep -oP '(?<=dm)[0-9]+(\.[0-9]+)?')
      width=$(echo "$file" | grep -oP '(?<=width)[0-9]+(\.[0-9]+)?')

 
                                            #dedispersing 
      prepdata -nobary -noclip -dm ${DM} -o test_single_dm${DM}_width${width} -filterbank ../test_single_dm${DM}_width${width}_inverted.fil | grep "Writing"

     
      echo "searching $file"

      single_pulse_search.py -m 70 -b test_single_dm${DM}_width${width}.dat | grep "Found"


      dm_index=$(python3 -c "print(int(($DM - $DM_start) / $DM_step))")
      width_index=$(python3 -c "print(int(($width - $width_start) / $width_step))")
      


      candfile="test_single_dm${DM}_width${width}.singlepulse"
      #echo $(pwd)
      #echo "$candfile"
      if [ -z "$candfile" ]; then
          echo "candfile=$candfile"
          echo "no result pulse for ${file}"
          SNR=0
      else  
          SNR=$(awk '
              # Skip lines starting with a comment character (#)
              $1 ~ /^#/ { next }
              # Store the maximum value of the second column
              NR == 2 {
              max = $2
              next
              }

              # Compare subsequent values in the second column to find the maximum
              NR > 2 && $2 > max {
              max = $2
              }

              END { print max }  
              ' "$candfile")

         boxcar=$(awk '
               # Skip lines starting with a comment character (#)
               $1 ~ /^#/ { next }
               # Store the maximum value of the second column
               NR == 2 {
               max = $2
               maxb=$5
               next
               }

               # Compare subsequent values in the second column to find the maximum
               NR > 2 && $2 > max {
               max = $2
               maxb=$5
               }

               END { print maxb }
               ' "$candfile")
            
	        
      fi
      
      if [ -z "$SNR" ]; then
         matrix[$width_index,$dm_index]=0
      else
         matrix[$width_index,$dm_index]=$SNR
      fi

      if [ -z "$boxcar" ]; then
         #echo "$dm_index,$width_index,$sigma"
         boxcar_matrix[$width_index,$dm_index]=0
      else
         #echo "$dm_index,$width_index,$sigma"
         boxcar_matrix[$width_index,$dm_index]=$boxcar
      fi
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
cat ${model}_output/${model}.txt
