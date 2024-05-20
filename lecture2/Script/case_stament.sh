#!/bin/bash
echo "What's the weather like tomorrow?"
read weather
case $weather in
sunny | warm ) echo "Nice weather: " $weather
;;
cloudy | cool ) echo "Not bad weather: " $weather
;;
rainy | cold ) echo "Terrible weather: " $weather
;;
* ) echo "Don't understand"
;;
esac 
