#!/bin/bash
source ~/.bash_profile

# This is where we do the interactive stuff
PS3='Please enter your choice: '
options=("Current" "Default (Empty)" "Synthesis" "Processing" "Analysis")
select opt in "${options[@]}"
do
    case $opt in
        "Current")
            NEWPLAYGROUND="Playground.m"
            break
            ;;
        "Default (Empty)")
            NEWPLAYGROUND="DefaultPlayground.m"
            break
            ;;
        "Synthesis")
            NEWPLAYGROUND="SynthesisPlayground.m"
            break
            ;;
        "Processing")
            NEWPLAYGROUND="ProcessingPlayground.m"
            break
            ;;
        "Analysis")
            NEWPLAYGROUND="AnalysisPlayground.m"
            break
            ;;
        *) echo invalid option;;
    esac
done
if [ $NEWPLAYGROUND != "Playground.m" ]; then
  cp Playground/Playgrounds/$NEWPLAYGROUND Playground/Playgrounds/Playground.m
fi
echo "Watching Playground, Press Control-c when finished."
open Playground.xcworkspace

kicker -sql 0.05 Playground 2>/dev/null
