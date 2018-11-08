# AudioKitCore/Common

This directory contains basic building-block C++ classes used in several AudioKit DSP modules.

## ADSREnvelope
Basic four-segment envelope generator with linear *Attack*, *Decay*, *Sustain* and *Release* segments, plus a special "silence" segment used to quickly (but not instantaneously) silence a note before re-triggering it.

This is a stand-alone class at the moment, but it will eventually become one of several specialized subclasses of a more general multi-segment "Envelope" class.

## FunctionTable
Basic one-dimensional *lookup table* for tabulated functions, with *linear interpolation* between adjacent values, and a choice of either *cyclical addressing* (for periodic functions; see **FunctionTableOscillator**) or *bounded addressing* (for non-periodic functions; see **WaveShaper**).

Utility functions are provided to initialize the table data to triangle, sinusoid, and sawtooth waves (useful for LFOs) and exponential curves (useful for wave shaping).

## FunctionTableOscillator
Simple oscillator based on samples of a periodic function stored in an **FunctionTable**.

## WaveShaper
Wraps an **FunctionTable** and provides saved scale and offset parameters for both input (x) and output (y) values.

## LinearRamper
Basic digital ramp generator, with a floating-point *value* member variable which advances by small increments toward a specified *target* value. A core building-block for envelope generators.

## ResonantLowPassFilter
A simple digital low-pass filter with resonance, adapted from an Apple code sample.

## SustainPedalLogic
Encapsulates the basic logic for tracking the up/down state of MIDI keys and a sustain pedal, to allow a multi-voice instrument to determine how to respond to *key-down*, *key-up*, *pedal-down*, and *pedal-up* events.

