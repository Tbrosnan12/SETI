#!/bin/csh

set val = $1

echo "Iteration" $val
mkdir "iter"$val; cd "iter"$val; cp ../../*py .; cp ../../*sh .
schedtool -a $val -e bash create.sh 0 200 100 4 5 1
schedtool -a $val -e bash transientx.sh
cd ..