#!/bin/bash
for name in `ls /home/huyha/`; do
if [[ -f "/home/huyha/$name" ]];then
    echo "$name is file"
elif [[ -d "/home/huyha/$name"  ]];then
    echo "$name is directory"
else
    echo "$name is orther type"
fi
done
