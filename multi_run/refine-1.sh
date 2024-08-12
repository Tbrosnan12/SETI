#!/bin/bash
model=$1

cd output_files
cp injected_snr.txt ../
if [ -f "${model}_boxcar.png" ]; then
    cp ${model}_boxcar.png ../
fi
cp ${model}_output/${model}.txt ../
cd ..
rm -r output_files
rm *py && rm *sh && rm -r python