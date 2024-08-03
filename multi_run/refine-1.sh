#!/bin/bash
touch out.txt
model=$1

cd output_files
mv injected_snr.txt ../
if [ -f "boxcar.png" ]; then
    mv boxcar.png ../
fi
mv ${model}_output/${model}.txt ../
mv ranges.txt ../
cd ..
rm -r output_files
rm *py && rm *sh && rm -r python