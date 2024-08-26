#!/bin/bash

model=$(grep "model=" multi_core.sh | awk -F '=' '{print $2}')
DM_start=$(grep "DM_start=" multi_core.sh | awk -F '=' '{print $2}')
DM_end=$(grep "DM_end=" multi_core.sh | awk -F '=' '{print $2}')
DM_step=$(grep "DM_step=" multi_core.sh | awk -F '=' '{print $2}')
width_start=$(grep "width_start=" multi_core.sh | awk -F '=' '{print $2}')
width_end=$(grep "width_end=" multi_core.sh | awk -F '=' '{print $2}')
width_step=$(grep "width_step=" multi_core.sh | awk -F '=' '{print $2}')

if [ "$#" == 1 ] && [ $1 == "plot" ]; then
    echo "remaking plot"
    model=$(grep "model=" multi_core.sh | awk -F '=' '{print $2}')
else

  declare -A matrix
  declare -A rms_matrix

  n=$(ls -d iter* 2>/dev/null | wc -l)
  first=1
  count=1

  if [ -f "out.txt" ]; then
    rm out.txt
    echo "removed previous out.txt"
  fi
  if [ -f "std.txt" ]; then
    rm std.txt
    echo "removed previous std.txt"
  fi
  touch out.txt
  touch std.txt
  for dir in iter*; do
      echo -ne "refining iteration $count / $n\r"
      count=$(($count+1))

      cd $dir

      dm_range=$(echo " ($DM_end - $DM_start) / $DM_step "| bc)
      width_range=$( echo "($width_end - $width_start) / $width_step " | bc)
      if [ "$first" -eq  1 ]; then
          for i in $(seq 0 1 $dm_range); do
              for j in $(seq 0 1 $width_range); do
                reported=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' ${model}.txt)
                injected=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' injected_snr.txt)
                ratio=$( echo "$reported/$injected" | bc -l )
                rms=$( echo "($reported/$injected)^2" | bc -l)
                matrix[$j,$i]=$ratio
                rms_matrix[$j,$i]=$rms
              done
          done
          #echo "${matrix[0,0]},${matrix[1,0]},${matrix[2,0]},${matrix[3,0]}"
          first=0
      else
          for i in $(seq 0 1 $dm_range); do
              for j in $(seq 0 1 $width_range); do
                reported=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' ${model}.txt)
                injected=$(awk -v i="$( echo $i+1 | bc )" -v j="$( echo $j+1 | bc )" 'NR==i {print $j}' injected_snr.txt)
                ratio=$( echo "${matrix[$j,$i]}+($reported/$injected)" | bc -l )
                rms=$( echo "${rms_matrix[$j,$i]}+($reported/$injected)^2" | bc -l)
                matrix[$j,$i]=$ratio
                rms_matrix[$j,$i]=$rms
              done
          done
      fi
      cd ..  
    done
  #echo "dm_range=$dm_range"
  #echo "width_range=$width_range"

  for i in $(seq 0 1 $dm_range); do
      row=""
      row2=""
      for j in $(seq 0 1 $width_range); do
          mean=$( echo "${matrix[$j,$i]}/$n" | bc -l)
          standard_deviation=$( echo "sqrt((${rms_matrix[$j,$i]}/$n)-(${mean}^2))" | bc -l)
          row+=" $mean"
          row2+=" $standard_deviation"
      done
      echo "$row" >> "out.txt"
      echo "$row2" >> "std.txt"
  done
fi
python3 graph_multi.py out.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step $model
python3 graph_multi.py std.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step $model_std 4 5 0 5 