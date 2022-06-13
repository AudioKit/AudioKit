# Contributing Code

Notes about making updates, bug fixes, features, or improving the documentation.

## Overview

When you want to modify AudioKit, fork the repository,
make your changes, and send us a [pull request](https://github.com/audiokit/AudioKit/pulls).

## Documentation / Commenting

Ideally, our code would not need comments because it would be so clear to read the code directly, but this is often impossible, so commenting is important.

### Comments should be documentation generating

Using xcode, create documentation comments is as easy as `Command-Option-/` on the line class, struct, enum, method, or variable is defined on. This will create placeholders to fill in, as shown below:

```
    /// <#Description#>
    /// - Parameters:
    ///   - audioFile: <#audioFile description#>
    ///   - maximumFrameCount: <#maximumFrameCount description#>
    ///   - duration: <#duration description#>
    ///   - prerender: <#prerender description#>
    ///   - progress: <#progress description#>
    /// - Throws: <#description#>
    public func renderToFile(_ audioFile: AVAudioFile,
                             maximumFrameCount: AVAudioFrameCount = 4_096,
                             duration: Double,
                             prerender: (() -> Void)? = nil,
                             progress: ((Double) -> Void)? = nil) throws {
```                                 

## Style Guide

AudioKit is a Swift framework with internal code in C and C++.  For this reason,
we mostly use Swift conventions throughout our code, even in the C-variants. We almost entirely defer to
Erica Sadun's style choices in her book, [Swift Style](https://pragprog.com/book/esswift/swift-style).

Audio programming is full of abbreviations, difficult concepts, and new terminology, so to help alleviate the difficulty associated with reading audio code, we adopt the following variable naming conventions.

### Variable naming

#### Variable naming should be consistent across languages (ie. Swifty)

Since the highest level language we're using is Swift, students of AudioKit will learn that first.
As they dig deeper, they will be exposed to other languages, specifically C-variants, and they should
not be surprised at the variables in those languages.  In specific, this means camel case variable naming
with a lowercase first character (except for Classes, which are uppercase).  No Hungarian notation.

### Variable names with descriptors should have descriptors in front of the word

Example: `leftOutput` not `outputLeft`

The primary reason for adding descriptors to the right is some sort of vertical alignment or alphabetical arrangement to your variables. Unfortunately, English is the opposite from this, so to maximize readability, the descriptors come before the nouns.

#### Variables should not include the units of the variable unless absolutely necessary

Example: `frequency` not `Hz`

Variable units are very important, and it could have been our standard to always use unit as in 'frequencyInHz' but that can get pretty long so units were dropped and we choose instead to highlight the concept.  If units could be checkable as in Mathematica, that would be great, perhaps some day.

Exception: For clarity when converting between types.

#### Only variable names of collections are pluralized

Example: `channelCount` not `numberOfChannels`

#### Avoid abbreviations unless absolutely obvious

#### Acronyms are always all CAPS or all lowercase, not camel case

Examples: `enableMIDI` not `enableMidi` and `adsrEnvelope` not `AdsrEnvelope`

While some acronyms are pronounceable (like 'MIDI') many are not, and when you see words in camel case variables, we expect to be able to mentally separate and pronounce the components as words.  Capitalization alerts the reader of this.  The exception to all caps is all lower case, for when the acronym appears in the beginning of the variable name.

#### Time Intervals are "Durations"

When you're writing audio apps, timing is often a very important issue.  The distinction between the time something takes to be done and the time the action should start can become confusing if both are called "times".  So, to distinguish, any amount of time is labeled as a Duration and a time is an actual moment in time.

#### Boolean variable should start with "is" and if a verb, should end with "ed" or "ing"

Examples: `isLooping` not `loop` because loop can be misinterpreted as a noun and `isFilterEnabled` not `filterEnable` because the latter sounds like a verb.

