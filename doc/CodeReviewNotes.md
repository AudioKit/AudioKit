Overall Notes
=============

* Opcodes that have either control or audio rates work with setOutput:[opcodeInst control] pattern, but perhaps there's a better way like simple [opcode outputControl] and [opcode outputAudio].  Or to do it upon initialization, initAsControllerYaddaYaddaYadda.  At least, establish a parity between the way OCSProperty does it, which is pretty nice.
* For things that require lists (like some functionTables for instance), use an add function rather than sending an OCSParamArray 

### Syntactical niceties
* Change method signatures to not start with capital letters
* Reorder parameters in opcode signatures so that the initialization parameters come first and the performance parameters come second, like in the Csound documentation.
* Follow the Foscili model for property-izing everything. 


File Specific Notes
===================

### OCSFunctionTable
* Use an NSArray instead of a string for the parameters.
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)

### OCSGrain
* Is GrainPitch really a frequency?  If so, _that_ is confusing.

### OCSParamArray
* Does this type even need to exist?  Seems like at most it should be a category of NSArray.

### OCSProperty
* Do all properties need bounds?  Seems brittle to have them be optional but having the limits as accessible properties.  Adam loves the bounds for sliders, so it's an important feature to get right.

### OCSReverbSixParallelComb
* Doesn't follow any of the current OCS guidelines.
* This is a good case on study on how descriptive a class name should be.  Do we gain much from it named like this? NReverb seems better in a way.  It at least benefits from history.

### OCSWindowsTable
* Create separate methods for each type since Gauss and Kaiser take another parameter.