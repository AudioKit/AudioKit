# AudioKit Externals

This directory stores the platform-independent code of AudioKit.  Much of this should be factored into its own frameworks.

## AudioKitCore
C++ building-block classes developed by the AudioKit core group. All C++ code here lives in the *AudioKitCore* namespace.


## Soundpipe

Paul Batchelor's C-library of DSP algorithms by Paul Batchelor, some of which were adapted from code from Csound, Faust, Guitarix, and others.

## Sporth

Paul Batchelor's stack based DSP programming language, used as the basis for AudioKit's Operations.


## WavPack

David Bryant's [WavPack](http://www.wavpack.com/) audio-compression library. Primarily used by **AKSampler**.
