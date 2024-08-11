#!/bin/bash
model=$1

cd output_files
mv injected_snr.txt ../
if [ -f "${model}_boxcar.png" ]; then
    mv ${model}_boxcar.png ../
fi
mv ${model}_output/${model}.txt ../
cd ..
rm -r output_files
rm *py && rm *sh && rm -r python