#!/bin/bash

for i in {10..20}
do
if [[ $i -eq 12 ]]
then
echo i touch 12 
continue
fi
echo $i
done

