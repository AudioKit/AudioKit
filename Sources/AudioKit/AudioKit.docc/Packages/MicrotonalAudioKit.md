# Microtonal AudioKit Tuning Tables

These tuning tables were developed by Marcus Hobbs and used in the AudioKit Synth One iOS app.

<img src="https://github.com/AudioKit/Microtonality/blob/develop/images/synthone.jpg?raw=true" width="60%"/>

## Installation

Install with Swift Package Manager.

## Documentation

  - [TuningTableETNN](https://audiokit.io/Microtonality/documentation/microtonality/tuningtableetnn):
    helper object to simulate a Swift tuple for ObjC interoperability
  - [TuningTableDelta12ET](https://audiokit.io/Microtonality/documentation/microtonality/tuningtabledelta12et):
    helper object to simulate a Swift tuple for ObjC interoperability
  - [TuningTable](https://audiokit.io/Microtonality/documentation/microtonality/tuningtable):
    TuningTable provides high-level methods to create musically useful tuning tables
  - [TuningTableBase](https://audiokit.io/Microtonality/documentation/microtonality/tuningtablebase):
    TuningTableBase provides low-level methods for creating
    arbitrary mappings of midi note numbers to musical frequencies
    The default behavior is "12-tone equal temperament" so
    we can integrate in non-microtonal settings with backwards compatibility

<iframe width="560" height="315" src="https://www.youtube.com/embed/bVnHpBozSJ4?start=1975" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
