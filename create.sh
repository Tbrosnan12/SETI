#!/bin/bash

usage() {
    echo "Usage: $0 <DM_start> <DM_end> <DM_step> <width_start> <width_end> <width_step>"
    exit 1
}

if [ "$#" -lt 6 ]; then
   echo "Error: Invalid number of arguments."
   usage
fi
DM_start=$1
DM_end=$2
DM_step=$3
width_start=$4
width_end=$5
width_step=$6
amp=50

if [ -d "output_files" ]; then
   rm -r "output_files"
   echo "deleted output_files"
fi
mkdir output_files
cd output_files
touch injected_snr.txt

# Create the pulses
python3 ../simscript_thomas.py --dm_start ${DM_start} --dm ${DM_end} --step ${DM_step} --sig_start ${width_start} --sig_step ${width_step} --sig ${width_end} -N 1 -A $amp -s 5000
if [ $? -ne 0 ]; then
   echo "Error: Failed to run simscript_thomas.py"
   exit 1
fi

touch ranges.txt
echo $DM_start >> ranges.txt
echo $DM_end >> ranges.txt
echo $DM_step >> ranges.txt
echo $width_start >> ranges.txt
echo $width_end >> ranges.txt
echo $width_step >> ranges.txt