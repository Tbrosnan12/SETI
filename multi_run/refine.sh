#!/bin/bash

if [ -f "out.txt" ]; then 
  rm out.txt
  echo "removed out.txt"
fi
touch out.txt
declare -A matrix

n=$(ls -d iter* 2>/dev/null | wc -l)
first=1
echo "$n"

for dir in iter*; do
   cd $dir
   cd output_files
   mv injected_snr.txt ../
   mv reported_snr.txt ../
   mv ranges.txt ../
   cd ..
   rm -r output_files
   rm *py && rm *sh

   DM_start=$(awk 'NR == 1 { print $1 }' ranges.txt)
   DM_end=$(awk 'NR == 2 { print $1 }' ranges.txt)
   DM_step=$(awk 'NR == 3 { print $1 }' ranges.txt)
   width_start=$(awk 'NR == 4 { print $1 }' ranges.txt)
   width_end=$(awk 'NR == 5 { print $1 }' ranges.txt)
   width_step=$(awk 'NR == 6 { print $1 }' ranges.txt)

   dm_range=$(echo " ($DM_end - $DM_start) / $DM_step "| bc)
   width_range=$( echo "($width_end - $width_start) / $width_step " | bc)
   if [ "$first" -eq  1 ]; then
       for i in $(seq 0 1 $dm_range); do
          for j in $(seq 0 1 $width_range); do
            reported=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' reported_snr.txt)
            injected=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' injected_snr.txt)
            ratio=$( echo "$reported/$injected" | bc -l )
            matrix[$j,$i]=$ratio
            #echo "${matrix[$j,$i]},i=$i,j=$j"
            #echo "${matrix[0,0]},${matrix[1,0]},${matrix[2,0]},${matrix[3,0]}"
          done
       done
       #echo "${matrix[0,0]},${matrix[1,0]},${matrix[2,0]},${matrix[3,0]}"
       first=0
   else
       for i in $(seq 0 1 $dm_range); do
          for j in $(seq 0 1 $width_range); do
            reported=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' reported_snr.txt)
            injected=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' injected_snr.txt)
            ratio=$( echo "${matrix[$j,$i]}+($reported/$injected)" | bc -l )
            #echo "{matrix[$j,$i]}=${matrix[$j,$i]},ratio=$ratio ,i=$i,j=$j"
            matrix[$j,$i]=$ratio
          done
      done
   fi
   cd ..
done

for i in $(seq 0 1 $dm_range); do
    row=""
    for j in $(seq 0 1 $width_range); do
        val=$( echo "${matrix[$j,$i]}/$n" | bc -l)
        row+=" $val"
    done
    echo "$row" >> "out.txt"
done