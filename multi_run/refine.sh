#!/bin/bash
for dir in iter*; do 
   cd $dir
   cd output_files
   mv injected_snr.txt ../
   mv reported_snr.txt ../ 
   cd ..
   rm -r output_files
   rm *cp && rm*sh
   cd ..
done
