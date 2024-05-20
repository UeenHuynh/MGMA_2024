#!/bin/bash

#1
ls > name.txt
test -s name.txt
echo "1: $?"
#2
a=005
test $a -eq 5
echo "2: $?"
#3
b=1
test 001 == $b
echo "3: $?"
#4
test -d / 
echo "4: $?"
#5
false && test 2 -gt 1  
echo 5: $? 