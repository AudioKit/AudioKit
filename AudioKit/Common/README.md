# AudioKit Common Code (same across all platforms)

## Internals

Internals contains code that is not usually needed to be accessed by the casual AudioKit user. This is the core of the AudioKit engine.

## MIDI

Most of AudioKit's Musical Instrument Digital Interface (MIDI) functionality can be found here. 

## Nodes

AudioKit's connectable audio units are known as nodes and they can be either generators or effects.

## Operations

AudioKit operations are another set of connectible audio structures that live inside a single node.

## Taps

Taps use the data in the audio stream (at a specific point in the signal chain) as source material for processing separately.  AudioKit contains several different kinds of taps all of which are found here.

## Tests

AudioKit's tests can be cross-platform (though currently they are only used by the iOS-based AudioKit test suite) so they are kept here.

## User Interface
 
User interface elements that work on all platforms including a variety of audio plot types.  Most user interface is not cross-platform and will be found in platform specific directories outside of this Common folder.

