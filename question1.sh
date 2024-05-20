#!/bin/bash

num1=5
num2=10
num3=$(($num1+$num2))

echo $(($num1 + $num2 - $num3))
echo $num3"
echo " $1 % $num3" | bc
