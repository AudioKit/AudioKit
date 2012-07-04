To Do
=====
* Make PluckDrum & PluckString Examples
* Create the fof opcode and example
* Write an audio processor that outputs something back for instance fft
* Get Adam set up with appledoc

Notes
=====

* Opcodes that have either control or audio rates work with 
setOutput:[opcodeInst control] pattern, but perhaps there's a better way like 
simple [opcode outputControl] and [opcode outputAudio].  Or to do it upon 
initialization, initAsControllerYaddaYaddaYadda.  At least, establish a parity 
between the way OCSProperty does it, which is pretty nice.

* For things that require lists (like some fTables for instance), use an add 
function rather than sending an OCSParameterArray 

* Create objects like OCSEvents, OCSActions, and OCSSequences for controlling 
the way notes are fired off, parameters are changed, and actions chained.

* Create the notion of OCSEnsembles or OCSSections, in which multiple 
instruments can be defined, but given an interface as one thing.  

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