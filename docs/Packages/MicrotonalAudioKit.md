# Microtonal AudioKit Tuning Tables

These tuning tables were developed by Marcus Hobbs and used in the AudioKit Synth One iOS app.

<img src="https://github.com/AudioKit/MicrotonalAudioKit/blob/develop/images/synthone.jpg?raw=true" width="60%"/>

## Installation via Swift Package Manager

To add MicrotonalAudioKit to your Xcode project, select File -> Swift Packages -> Add Package Depedancy. Enter `https://github.com/AudioKit/MicrotonalAudioKit` for the URL. 

## Documentation

  - [TuningTableETNN](https://github.com/AudioKit/MicrotonalAudioKit/wiki//TuningTableETNN):
    helper object to simulate a Swift tuple for ObjC interoperability
  - [TuningTableDelta12ET](https://github.com/AudioKit/MicrotonalAudioKit/wiki//TuningTableDelta12ET):
    helper object to simulate a Swift tuple for ObjC interoperability
  - [TuningTable](https://github.com/AudioKit/MicrotonalAudioKit/wiki//TuningTable):
    TuningTable provides high-level methods to create musically useful tuning tables
  - [TuningTableBase](https://github.com/AudioKit/MicrotonalAudioKit/wiki//TuningTableBase):
    TuningTableBase provides low-level methods for creating
    arbitrary mappings of midi note numbers to musical frequencies
    The default behavior is "12-tone equal temperament" so
    we can integrate in non-microtonal settings with backwards compatibility

<iframe width="560" height="315" src="https://www.youtube.com/embed/bVnHpBozSJ4?start=1975" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>