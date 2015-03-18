#!/bin/bash
source ~/.bash_profile

# This is where we do the interactive stuff
PS3='Please enter your choice: '
options=(
    "Current"
    "Default (Empty)"
    "Synthesis"
    "Table"
    "Processing"
    "Microphone Analysis"
    "VC Oscillator"
)
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
        "Table")
            NEWPLAYGROUND="TablePlayground.m"
            break
            ;;
        "Processing")
            NEWPLAYGROUND="ProcessingPlayground.m"
            break
            ;;
        "Microphone Analysis")
            NEWPLAYGROUND="MicrophoneAnalysisPlayground.m"
            break
            ;;
        "VC Oscillator")
            NEWPLAYGROUND="VCOscillatorPlayground.m"
            break
            ;;
        *) echo invalid option;;
    esac
done
if [ $NEWPLAYGROUND != "Playground.m" ]; then
  cp Examples/$NEWPLAYGROUND Playground/Playground.m
fi
echo "Starting Playground, Press Control-c when finished."
open Playground.xcworkspace

kicker -sql 0.05 Playground 2>/dev/null
