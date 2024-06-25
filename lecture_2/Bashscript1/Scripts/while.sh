#!/bin/bash
declare -i counter
counter=10
while [$counter -gt 2]; do
echo The counter is $counter
counter=counter-1
done 
