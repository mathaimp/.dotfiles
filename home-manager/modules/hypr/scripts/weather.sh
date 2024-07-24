#!/usr/bin/env bash

apiKey=""
defaultLocation=""
unit="metric"
UseIcons="True"
FileLoc="$HOME/.config/lock"

ConfigFile="$FileLoc/weather.rc"

forcastFile="$FileLoc/forcast.json"

if [ "$1" == "-r" ];then
    shift
    ConfigFile="$1"
    shift
fi

if [ -f "$ConfigFile" ];then
    readarray -t line < "$ConfigFile"
    apiKey=${line[0]}
    defaultLocation=${line[1]}
    degreeCharacter=${line[2]}
    UseIcons=${line[3]}
fi

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
