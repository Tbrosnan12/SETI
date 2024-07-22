#!/bin/bash

if [ -d "iter0" ]; then
  rm -r iter*
  echo "removing previous data"
fi

usage() {
    echo "Usage: $0  <start cpu No.> <end cpu No.>"
    exit 1
}

if [ "$#" -lt 2 ]; then
    echo "Error: Invalid number of arguments."
    usage
fi

start=$1
end=$2

for i in $(seq  $start 1 $end); do
   csh schedtool.csh $i &
done
