#!/bin/bash


a1=`cat ./homework/fa1.txt|grep  ">"`
a2=`cat ./homework/fa1.txt|grep -v ">"|wc -c`
b1=`cat ./homework/fa2.txt|grep  ">"`
b2=`cat ./homework/fa2.txt|grep -v ">"|wc -c`

if [[ $a2 -gt $b2 ]]; 
then
echo "$a1"
echo "Length:$a2"
else
echo "$b1"
echo "Length:$b2"
fi



