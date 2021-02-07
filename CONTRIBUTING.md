# Contributing to AudioKit

AudioKit is a Swift framework with internal code in C and C++.  For this reason,
we mostly use Swift conventions throughout our code, even in the C-variants. We almost entirely defer to
Erica Sadun's style choices in her book,[Swift Style](https://pragprog.com/book/esswift/swift-style).

## Names

Audio programming is full of abbreviations, difficult concepts, and new terminology, so to help alleviate the difficulty associated with reading audio code, we adopt the following variable naming conventions.

### Variable naming should be consistent across languages (ie. Swifty)

Since the highest level language we're using is AudioKit, students of AudioKit will learn that first.
As they dig deeper, they will be exposed to other languages, specifically C-variants, and they should
not be surprised at the variables in those languages.  In specific, this means camel case variable naming
with a lowercase first character (except for Classes, which are uppercase).  No Hungarian notation.

### Variable names with descriptors should have descriptors in front of the word

Example: 'leftOutput' not 'outputLeft'

The primary reason for adding descriptors to the right is some sort of vertical alignment or alphabetical arrangement to your variables. Unfortuanately, English is the opposite from this, so to maximize readability, the descriptors come before the nouns.

### Variables should not include the units of the variable unless absolutely necessary

Example: 'frequency' not 'Hz'

Variable units are very important, and it could have been our standard to always use unit as in 'frequencyInHz' but that can get pretty long so units were dropped and we choose instead to highlight the concept.  If units could be checkable as in Mathematica, that would be great, perhaps some day.

Exception: For clarity when converting between types.

### Only variable names of collections are pluralized

Example: 'channelCount' not 'numberOfChannels'

### Avoid abbreviations and shortenings unless absolutely obvious

### Acronyms are always all CAPS or all lowercase, not camel case

Examples: 'enableMIDI' not 'enableMidi' and 'adsrEnvelope' not 'AdsrEnvelope'

While some acronyms are pronouncable (like 'MIDI') many are not, and when you see words in camel case variables, we expect to be able to mentally separate and pronounce the components as words.  Capitalization alerts the reader of this.  The exception to all caps is all lower case, for when the acronym appears in the beginning of the variable name.

### Time Intervals are "Durations"

When you're writing audio apps, timing is often a very important issue.  The distinction between the time something takes to be done and the time the action should start can become confusing if both are called "times".  So, to distinguish, any amount of time is labeled as a Duration and a time is an actual moment in time.

### Boolean variable should start with "is" and if a verb, should end with "ed" or "ing"

Examples: 'isLooping' not 'loop' and 'isFilterEnabled' not 'filterEnable'

## Documentation / Commenting

Ideally, our code would not need comments because it would be so clear to read the code directly, but this is often impossible, so commenting is important.

### Comments should be documentation generating

This requires you to use triple slash commenting usually on the lines above the item being commented on.

### Folders should contain a README.md

The README.md file should attempt to describe the contents of the folder, including files and sub folders.
