TO DO
=====

* Debug Grain Birds
* Combine similar opcodes like the two OCSSegmentArray
* For things that accept multiple inputs, use an add function rather than sending an OCSParamArray 

* Add the fof opcode
* Create an example that uses PluckDrum and PluckString
* Write an audio processor that outputs something to Objective-C
* Make a MIDI handling class
* Consider whether an OCSProperty need bounds or if they should be optional or handled elsewhere.
* Rewrite OCSWindowsTable with separate methods for each type since Gause and Kaiser take another parameter.


GENERAL IMPROVEMENTS TO MAKE
============================
* Rewrite Github readme as if we were already open-sourced.
* Reorder parameters in opcode signatures so that the initialization parameters come first and the performance parameters come second, like in the Csound documentation.
* Make sure the opcode functionalities are complete, or else make a todo note in the docs.
* Improve examples without making them hard to understand.  Better .xibs.

ALWAYS MORE
===========

* More documentation, both as comments and in the documentation folder
* More Opcodes
* More Function Tables
* More UDOs
* More Examples

NOTES
=====

* OCSPropertyManager also contains MidiIn methods which aren't used and probably won't stay in 
OCSProperty when we do use them.
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)
* some csound helper functions should be handled exclusively in ocs, like cpspch
* output as either k or a rate is a problem for opcodes already containing multiple inits. (see oscillator and linsegr)
* need OCSProperty to deal with all 3 output types, need a way to do this better than BOOL and conditionals
