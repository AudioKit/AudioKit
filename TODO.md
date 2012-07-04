To Do
=====
* Make PluckDrum & PluckString Examples
* Create the fof opcode and example
* Write an audio processor that outputs something back for instance fft
* Get Adam set up with appledoc

### Syntactical niceties

* Reorder parameters in opcode signatures so that the initialization parameters 
come first and the performance parameters come second, like in the Csound documentation.

* Follow the FMOscillator model for property-izing everything and using 
Csound manual terminology for the implementation variables.

Untested Stuff
==============
* OCSArrayTable
* OCSExponentialCurvesTable - not all method, especial those using pairing
* OCSNReverb - longer init method
* OCSPluckDrum
* OCSPluckString
* OCSScale