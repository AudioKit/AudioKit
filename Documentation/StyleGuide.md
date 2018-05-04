# AudioKit Style Guide

## Variable naming should be consistent across languages (ie. Swifty)

Since the highest level language we're using is AudioKit, students of AudioKit will learn that first.  
As they dig deeper, they will be exposed to other languages, specifically C-variants, and they should
not be surprised the variables in those languages.  In specific, this means camel case variable naming
with a lowercase first character (except for Classes, which are uppercase).  No Hungarian notation.

## Variable names with descriptors should have descriptors in front of the word

Example: 'leftOutput' not 'outputLeft'

## Variables should not include the units of the variable unless absolutely necessary

Example: 'frequency' not 'Hz'

## Only variable names of collections are pluralized

Examples: 'channelCount' not 'numberOfChannels'

## Avoid abbreviations and shortenings unless absolutely obvious

## Acronyms are always all CAPS or all lowercase, not camelCase

 Examples: 'enableMIDI' not 'enableMIDI' and 'midiChannel' not 'MIDIChannel' or 'MidiChannel'

## Time Intervals are "Durations"

## Boolean variable should start with "is" and if a verb, should end with "ed" or "ing"

Examples: 'isLooping' not 'loop' and 'isFilterEnabled' not 'filterEnable'

## Comments should documentation generating

## Comments should appear on the line prior to the code

## Folders should contain a README.md