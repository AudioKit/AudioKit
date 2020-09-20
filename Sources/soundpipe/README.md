Soundpipe
=========

Soundpipe is a lightweight music DSP library written in C. It aims to provide
a set of high-quality DSP modules for composers, sound designers,
and creative coders. 

Soundpipe supports a wide range of synthesis and audio DSP 
techniques which include:

- Classic Filter Design (Moog, Butterworth, etc)
- High-precision and linearly interpolated wavetable oscillators
- Bandlimited oscillators (square, saw, triangle)
- FM synthesis
- Karplus-strong instruments
- Variable delay lines
- String resonators
- Spectral Resynthesis
- Partitioned Convolution
- Physical modeling
- Pitch tracking
- Distortion
- Reverberation
- Samplers / sample playback
- Padsynth algorithm
- Beat repeat
- Paulstretch algorithm
- FOF and FOG granular synthesis
- Time-domain pitch shifting

More information on specific Soundpipe modules can be found in the
[Soundpipe module reference guide](https://paulbatchelor.github.com/res/soundpipe/docs/).

Features
---------
- Sample accurate timing
- Small codebase
- Static library
- Easy to extend
- Easy to embed

The Soundpipe Model
-------------------

Soundpipe is callback driven. Every time Soundpipe needs a frame, it will
call upon a single function specified by the user. Soundpipe modules are
designed to process a signal one sample at a time.  Every module follows the
same life cycle:

1. Create: Memory is allocated for the data struct.
2. Initialize: Buffers are allocated, and initial variables and constants
are set.
3. Compute: the module takes in inputs (if applicable), and generates a
single sample of output.
4. Destroy: All memory allocated is freed.
