TO DO
=====

* Consider signal as a term to use for audio rate stuff? 
* Make play events NSLog from within the instrument.
* Write an audio processor that outputs something to Objective-C
* Make a MIDI module that makes more sense than Csound's current midi implementation / Disconnect UIWidgets
* optional argument for OCSWindowsTable (used by Gaussian and Kaiser ?sigma)
* Consider whether an OCSProperty need bounds or if they should be optional or handled elsewhere.
* Consider whether adjectives go first or last in ClassNames.
  OCSSineTable and OCSParamConstant are inconsistent as are LoopingOscillator and OutputMono.
  Benefit to adjectives last is alphabetical grouping and benefit to adjectives first
  is readability.


ALWAYS MORE
===========

* More complete implementations of opcodes
* More Opcodes (fix up OCSPluck)
* More OCSFunctionTable subclasses
* More UDOs
* More Examples

NOTES
=====

* Consider units and rates in opcodes and properties
* OCSPropertyManager also contains MidiIn methods which aren't used and probably won't stay in 
OCSProperty when we do use them.
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)
* some csound helper functions should be handled exclusively in ocs, like cpspch
* output as either k or a rate is a problem for opcodes already containing multiple inits. (see oscillator and linsegr)
* need OCSProperty to deal with all 3 output types, need a way to do this better than BOOL and conditionals
