#!/usr/bin/env bash

apiKey=""
defaultLocation=""
unit="metric"
UseIcons="True"

ConfigFile="$HOME/.config/weather/weather.rc"

forcastFile="$HOME/.config/weather/forcast.json"

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

if [ ! -f $forcastFile ]; then
    curl "https://api.openweathermap.org/data/2.5/weather?q=$defaultLocation&units=$unit&appid=$apiKey" -o $forcastFile
fi

city=$(jq -r '.name' $forcastFile)

if [[ ! ($city == $defaultLocation) ]]; then
    curl "https://api.openweathermap.org/data/2.5/weather?q=$defaultLocation&units=$unit&appid=$apiKey" -o $forcastFile
    city=$(jq -r '.name' $forcastFile)
    if [[ $city == "" ]]; then
        echo "City does not exist. Check Config File"
        exit 0
    fi
fi

if [ $(expr $(date +%s) - $(jq -r '.dt' $forcastFile)) -ge 600 ]; then
    curl "https://api.openweathermap.org/data/2.5/weather?q=$defaultLocation&units=$unit&appid=$apiKey" -o $forcastFile
fi


country=$(jq -r '.sys.country' $forcastFile)
forcast=$(jq -r '.weather.[].description' $forcastFile)
forcast=$(echo "$forcast" | sed -e "s/\b\(.\)/\u\1/g")
temp=$(jq -r '.main.temp' $forcastFile)
temp=$(printf %.f $temp)

echo "$defaultLocation, $country - $forcast, $temp°C"
