#!/bin/bash
n=0

while [[ $n -le 10 ]]
do
if [[ $n -eq 8 ]]
then
echo "reach"
fi
echo $n
n=$(($n+1))
done

