# Contributing Code

Notes about making updates, bug fixes, features, or improving the documentation.

## Overview

When you want to modify AudioKit, fork the repository,
make your changes, and send us a [pull request](https://github.com/audiokit/AudioKit/pulls).

## Documentation / Commenting

Ideally, our code would not need comments because it would be so clear to read the code directly, but this is often impossible, so commenting is important. To publish documentation on audiokit.io please follow the guides in [docgen repository](https://github.com/AudioKit/docgen)  and [audiokit.io repository](https://github.com/AudioKit/audiokit.io)  

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

## Testing

It's important to us that our work is tested and proved to build successfully across as many platforms as possible. AudioKit and all it's packages and project have implemented tests using `XCTestCase`. Using Github's "Actions" continuous integration system all tests are run as soon at it is commited to the repository. The results of these automated tests can be found on our [GitHub Page](https://github.com/audiokit/). Xcodes built in support for `XCTestCase` is widely used within all packages.

AudioKit implements extensions to `AFAudioBuffer` to help developing tests. A MD5 Hash value of the sound output is used to check if edited code still sounds like it should be. This makes automated, headless testing possible.

### Developing Tests

- Add new func or edit existing func as needed to `XCTestCase` 
- Add a `ValidatedMD5s.swift` file to your project, best to copy one of an existing package including all methods.
- Adjust the name of the TestCaseName and the test method in the `validatedMD5s` dictionary

Within the test method:
- Instantiate a AudioEngine
- Add nodes to the engines output
- Start the engine, set the output to a constant variable 
- Make some noise or music using the nodes
- Listen to the output using [`audition()`](https://github.com/AudioKit/AudioKit/blob/main/Sources/AudioKit/Internals/Utilities/AVAudioPCMBuffer+audition.swift) of your output
- If you're satisfied with how it sounds: set a breakpoint in `validatedMD5s`, run the test again and copy-paste the localMD5 to the dictionary
- Verify the output with [`testMD5()`](https://github.com/AudioKit/AudioKit/blob/main/Sources/AudioKit/Audio%20Files/AVAudioPCMBuffer+Utilities.swift)

After you have developed the tests, remove `audition()` line. 


Example of a simple test:
```
func testDefault() {
    let engine = AudioEngine()
    let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
    let player = AudioPlayer(url: url)!
    engine.output = Compressor(player)
    let audio = engine.startTest(totalDuration: 1.0)
    player.play()
    audio.append(engine.render(duration: 1.0))
    
// remove following line when satisfied with the sound
    audio.audition()

    testMD5(audio)
}
```

Example `ValidatedMD5s.swift`
```

import AVFoundation
import XCTest

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = description
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }
}

let validatedMD5s: [String: String] = [
    // Get the MD5 value: play the sound using .audition of AudioEngine and set a breakpoint on the line below
    "-[XCTestCaseName testDefault]": ["3064ef82b30c512b2f426562a2ef3448"],
]


```

### Runing Tests

- To run tests of your App: Refer to [Apple documentation on XCTest](https://developer.apple.com/documentation/xctest)) as well as on [Xcode](https://developer.apple.com/documentation/xcode/testing) 
- To locally run tests fo a package: 
     - Drag'n'drop the folder of the package onto Xcodes icon in the Dock. The package will open even when there is no .xcodeproj or .xcodescheme files available'
     - Choose a Simulator as Run destination
     - Start the tests using Menu Product > Test (or hit cmd-U)
     - In rare cases, the package opens without the possibility to run tests. Try deleting the local directory and clone again from remote. 

## Continous Integration

Most of our projects have GitHub actions to automatically build and test after each commit. They include a Hound to check for Style Guide violations.


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

