Overall Notes
=============

* Opcodes that have either control or audio rates work with setOutput:[opcodeInst control] pattern, but perhaps there's a better way like simple [opcode outputControl] and [opcode outputAudio].  Or to do it upon initialization, initAsControllerYaddaYaddaYadda.  At least, establish a parity between the way OCSProperty does it, which is pretty nice.
* For things that require lists (like some functionTables for instance), use an add function rather than sending an OCSParamArray 
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)
* Adam: Consider whether i-Rate Properties should be defined only in playWith methods and not outside... the reason is the awkwardness of setting up sequences.

### Syntactical niceties
* Reorder parameters in opcode signatures so that the initialization parameters come first and the performance parameters come second, like in the Csound documentation.
* Follow the FMOscillator model for property-izing everythin and usign Csound manual terminology for the implementation variables.


File Specific Notes
===================

### OCSFunctionTable
* Adam: Could we pull off calling these "functions" and losing the table?  It just seems a bit pedantic to explicitly state how the function is being stored.  I realize there are size and opcode issues, so it's something to discuss.

### OCSParamArray
* Does this type even need to exist?  Seems like at most it should be a category of NSArray.

### OCSProperty
* Adam: Do all properties need bounds?  Seems brittle to have them be optional but having the limits as accessible properties.  Adam loves the bounds for sliders, so it's an important feature to get right.

### OCSNReverb
* Adam: I don't think the non-simple initialization method has been tested.

### OCSSegmentArray
* Adam: Isn't linseg a subset of linsegr with both parameters as zero?  Would clean up the code a little.

### OCSWindowsTable
* Adam: Need to review with both of us what is happening with negative types and maximum value.
