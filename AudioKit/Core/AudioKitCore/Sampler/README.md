# AudioKitCore/Sampler

Platform-independent C++ *AudioKitCore::Sampler* class and its specialized component classes.

## AKSampler_Typedefs.h
This file defines three C ``struct``s used in the API for **Sampler**, which can be bridged to Swift. Because this is (Objective-)C code, it does not use the *AudioKitCore* namespace, instead using the "AK" name prefix used at the Swift level.

## Sampler
Class **Sampler** implements a complete multi-voice sample playback engine, roughly comparable to Apple's built-in **AUSampler**. It provides

* A dynamic pool of in-memory *sample buffers*
* A dynamic *key-map* defining how MIDI note-number, velocity pairs are used to select samples for playback
* A bank of 64 *voices*, each *voice* comprising all resources required to play a note (see below)
* A set of common *parameters* e.g. master volume, pitch bend, etc.
* Member functions to trigger note playback and interpret real-time parameter changes (e.g. pitch bend)
* Member functions to load and unload samples and build the key-map

## SamplerVoice
Class **SamplerVoice** represents one of the 64 voices of an **Sampler**, and comprises:

* pointer a *sample buffer*
* a *sample oscillator* to scan and play samples from the buffer
* two *resonant low-pass filters* (for Left and Right) channels
* two *ADSR envelope generators*, one for amplitude, one for filter cutoff

## SampleOscillator
Class **SamplerOscillator** is a very lightweight class for scanning through the samples of an **SampleBuffer** at a given speed, with *linear interpolation* between adjacent samples.

## SampleBuffer
Class **SampleBuffer** represents a sample loaded in memory. Class **KeyMappedSampleBuffer** adds metadata about the range of MIDI note numbers and velocity values which should trigger this sample.

Samples can be either mono or stereo, and have an associated MIDI note number (primarily for identification in a group of samples) and an associated pitch in Hz.
