#!/bin/bash

sum=$(($1+$2+$3))
mean=$((sum/$#))
echo "Sum: $sum"
echo "mean $mean"
bg=$1
if [[ $2 -gt $bg  &&  $2 -gt $3 ]] 
then
    bg=$2
    echo "$bg is the biggest"
elif [[ $3 -gt $bg ]]
then
    bg=$3
    echo "$bg is the biggest"
else
    echo "$bg is the biggest"
fi

if [[ $(($bg%2)) -eq 0 ]];then
echo "$bg is even number"
else
echo "$bg is odd number"
fi
