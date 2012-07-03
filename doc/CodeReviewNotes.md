Overall Notes
=============

* Opcodes that have either control or audio rates work with setOutput:[opcodeInst control] pattern, but perhaps there's a better way like simple [opcode outputControl] and [opcode outputAudio].  Or to do it upon initialization, initAsControllerYaddaYaddaYadda.  At least, establish a parity between the way OCSProperty does it, which is pretty nice.

* For things that require lists (like some fTables for instance), use an add function rather than sending an OCSParameterArray 

* Create objects like OCSEvents, OCSActions, and OCSSequences for controlling the way notes are fired off, parameters are changed, and actions chained.

* Create the notion of OCSEnsembles or OCSSections, in which multiple instruments can be defined, but given an interface as one thing.  

### Syntactical niceties
* Reorder parameters in opcode signatures so that the initialization parameters come first and the performance parameters come second, like in the Csound documentation.

* Follow the FMOscillator model for property-izing everything and using Csound manual terminology for the implementation variables.

* In the examples, place property bounds in the header file as constants that define the instrument.

File Specific Notes
===================
* MoreGrainViewController.m - not properly stopping all timers

Untested Stuff
==============
* OCSNReverb - longer init method
* OCSArrayTable
* OCSExponentialCurvesTable - not all method, especial those using pairing
* OCSScale
* OCSPluckDrum
* OCSPluckString
* OCSScale