#!/bin/bash

N=$1

for i in $( seq 0 1 $N); do
   bash Run.sh 0 3.184 | grep " "
done

python histogram.py -file temp2.txt -nbins 40
