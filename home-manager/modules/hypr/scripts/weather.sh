#!/usr/bin/env bash

apiKey="$1"
defaultLocation="Gachibowli"
unit="metric"
UseIcons="True"

forcastFile="/tmp/forcast.json"

if [ ! -e $forcastFile ];then
  curl "https://api.openweathermap.org/data/2.5/weather?q=$defaultLocation&units=$unit&appid=$apiKey" -o $forcastFile
fi

savedTime=$(jq -r '.dt' $forcastFile)
currentTime=$(date +%s)
timeDiff=$(expr $currentTime - $savedTime)

if [ $timeDiff -gt 600 ]; then
  curl "https://api.openweathermap.org/data/2.5/weather?q=$defaultLocation&units=$unit&appid=$apiKey" -o $forcastFile
fi

city=$(jq -r '.name' $forcastFile)

if [[ $city == "" ]]; then
    echo "No city found. Check config."
fi

country=$(jq -r '.sys.country' $forcastFile)
forcast=$(jq -r '.weather.[].description' $forcastFile)
forcast=$(echo "$forcast" | sed -e "s/\b\(.\)/\u\1/g")
temp=$(jq -r '.main.temp' $forcastFile)
temp=$(printf %.f $temp)

echo "$city, $country - $forcast, $temp°C"
