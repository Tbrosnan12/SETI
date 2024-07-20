#!/bin/bash

if [ -d "iter0" ]; then
  rm -r iter*
  echo "removing previous data"
fi

for i in $(seq 0 1 $1); do
   csh schedtool.csh $i &
done
