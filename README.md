Objective-Csound
================

Obective-Csound (OCS for short, pronounced "ox"), is a very important part of the 
H4Y technology stack. It minimizes the need for CSD files and provides an
in-Xcode syntax highlighter for Csound Opcodes, Function Tables, and more.   

TODO:

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

INDIGESTION:

* Develop convention for conditional initialization