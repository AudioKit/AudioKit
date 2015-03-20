#!/bin/bash
source ~/.bash_profile

# This is where we do the interactive stuff
PS3='Enter your choice: '
options=(
    "Run Current Playground"
    "Run Empty Playground"
    "Choose Playground from List"
)
NEWPLAYGROUND=""
select opt in "${options[@]}"
do
    case $opt in
        "Run Current Playground")
            break
            ;;
        "Run Empty Playground")
            NEWPLAYGROUND="DefaultPlayground.m"
            break
            ;;
        "Choose Playground from List")
            NEWPLAYGROUND="New"
            break
            ;;
        *) echo invalid option;;
    esac
done

if [ $NEWPLAYGROUND == "New" ]; then
    PS3='\nEnter the number of the playground you want: '
    options=($(ls Playgrounds))
    select opt in "${options[@]/Playground.m/}"
    do
        NEWPLAYGROUND=$opt"Playground.m"
        break
    done
fi

echo "Starting Playground, Press Control-c when finished."
kicker -sql 0.05 AudioKitPlayground/AudioKitPlayground ../AudioKit 2>/dev/null &
open AudioKitPlayground/AudioKitPlayground.xcworkspace

if [ $NEWPLAYGROUND != "" ]; then
  echo "Pausing for two seconds to allow the kicker to start."
  sleep 2
  echo "Copying the requested playground."
  cp Playgrounds/$NEWPLAYGROUND AudioKitPlayground/AudioKitPlayground/Playground.m
fi

wait
