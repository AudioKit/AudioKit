Overall Notes
=============

* Opcodes that have either control or audio rates work with setOutput:[opcodeInst control] pattern, but perhaps there's a better way like simple [opcode outputControl] and [opcode outputAudio].  Or to do it upon initialization, initAsControllerYaddaYaddaYadda.  At least, establish a parity between the way OCSProperty does it, which is pretty nice.
* For things that require lists (like some fTables for instance), use an add function rather than sending an OCSParamArray 
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)
* Create objects like OCSEvents, OCSActions, and OCSSequences for controlling the way notes are fired off, parameters are changed, and actions chained.
* Create the notion of OCSEnsembles or OCSSections, in which multiple instruments can be defined, but given an interface as one thing.  

### Syntactical niceties
* Reorder parameters in opcode signatures so that the initialization parameters come first and the performance parameters come second, like in the Csound documentation.
* Follow the FMOscillator model for property-izing everything and using Csound manual terminology for the implementation variables.


File Specific Notes
===================

### OCSExponentialCurvesTable
* Should allow the developer to add points to the arrays.  Also, allow the developer to give the paired parameters as two different arrays.  Not sure which initialization will be most useful.

### OCSFTable
* Standardize on how to deal with positive GenRoutine numbers mean the output is normalized to 1 and negative is not.

### OCSParamArray
* Does this type even need to exist?  Seems like at most it should be a category of NSArray.

### OCSProperty
* Force all properties to be initialized with bounds. 
* Place property bounds in the header file as constants that define the instrument.

### OCSNReverb
* Write an example to test the longer init method.  Perhaps should use this is an excuse to learn to write unit tests.
* Try to change the name to something more descriptive.