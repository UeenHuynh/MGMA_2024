#!/bin/bash

for i in {15..115..15}
do
if [[ $(($i%2)) -eq 0 && $(($i%10)) -eq 0 ]]
then
echo " $i is even and divisible for 10"
sleep 0.5
if [[ $i -eq 60 ]]
then
echo "number is reach 60"
fi
else 
echo " $i is odd and indivisible for 10"
fi
done 
