#!/bin/bash

touch /root/test.txt

if [[ $? -eq 0 ]];then
    echo "Done"
    exit 0
else
    echo "Error"
    exit 1
fi
echo "$?"
echo "bla bla bla"
