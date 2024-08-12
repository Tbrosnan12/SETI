#!/bin/bash/

target=$1

for dir in iter*; do
  mv $dir $target/$dir
done  
