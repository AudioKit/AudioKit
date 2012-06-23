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
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)

INDIGESTION:

* Opcodes don't get initialized "With Instrument" but instruments get initialized
"With Orchestra". I don't like the lack of parallelism here.  We do this so that
instrument play commands don't have to include reference to orchestra, but there
has to be a better way.

* Develop convention for conditional initialization