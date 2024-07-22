#!/bin/csh

#git clone https://github.com/Tbrosnan12/Presto_test
#cd Presto_test

set val = $1

    echo "Iteration" $val
    mkdir "iter"$val; cd "iter"$val; cp ../../*py .; cp ../../*sh .
    schedtool -a $val -e bash Run.sh range 0 2500 100 1 10 1
#    mv output_files/* "iter"$val && rm output_files/*
    cd .. 