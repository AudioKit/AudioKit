Objective-Csound
================

Obective-Csound (OCS for short, pronounced "ox"), is a very important part of the 
H4Y technology stack. It minimizes the need for CSD files and provides an
in-Xcode syntax highlighter for Csound Opcodes, Function Tables, and more.   

TODO:
* Make an i event also output the instrument's properties in addition to the now pretty useless i Name 0 duration
* Add UDO section to the orchestra / CSD, create UDO example 
* Add a bunch of UDOs because they should sound good almost out of the box
* Write an audio processor that outputs something to Objective-C
* Make a MIDI module that makes more sense than Csound's current midi implementation / Disconnect UIWidgets
* optional argument for OCSWindowsTable (used by Gaussian and Kaiser ?sigma)

ALWAYS MORE:
* More Opcodes (fix up Pluck)
* More Function Table subclasses
* More Examples

NOTES:

* Consider units and rates in opcodes and properties
* OCSPropertyManager also contains MidiIn methods which aren't used and probably won't stay in 
OCSProperty when we do use them.
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)

INDIGESTION:

* Develop convention for conditional initialization