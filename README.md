Objective-Csound
================

Potentially a very important part of the H4Y technology stack, Objective-Csound 
aims to eliminate the need for csd files and Csound-for-iOS hooks into code by 
representing every part of the Csound orchestra instruments as objects.  

TODO:

* Create a grain instrument to further test gen01 and ftgentmp
* Make a MIDI module that makes more sense than Csound's current midi implementation / Disconnect UIWidgets
* Create more opcodes (fix up CSDPluck)
* Create More Function Table subclasses
* Develop better examples
* optional argument for CSDWindowsTable (used by Gaussian and Kaiser ?sigma)

NOTES:

* Consider units and rates in opcodes and properties

RECENT UPDATE NOTES:

* CSDPropertyManager also contains MidiIn methods which aren't used and probably won't stay in 
CSDProperty when we do use them.

INDIGESTION:

* Develop convention for conditional initialization