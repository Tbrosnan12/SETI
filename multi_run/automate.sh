#!/bin/bash

N=$1

for i in $(seq 1 1 $N ); do
    bash multi_core.sh
    wait
    mv out.txt out${i}.txt
done

