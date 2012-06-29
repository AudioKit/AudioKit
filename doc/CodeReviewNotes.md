Overall Notes
=============

* Opcodes that have either control or audio rates work with setOutput:[opcodeInst control] pattern, but perhaps there's a better way like simple [opcode outputControl] and [opcode outputAudio].  Or to do it upon initialization, initAsControllerYaddaYaddaYadda.  At least, establish a parity between the way OCSProperty does it, which is pretty nice.
* For things that require lists (like some functionTables for instance), use an add function rather than sending an OCSParamArray 
* Some tables may not be interesting in csound any more, like gen02, better as arrays, converted to table during (addOpcode:)

### Syntactical niceties
* Change method signatures to not start with capital letters
* Reorder parameters in opcode signatures so that the initialization parameters come first and the performance parameters come second, like in the Csound documentation.
* Follow the Foscili model for property-izing everything. 


File Specific Notes
===================

### OCSFunctionTable
* Could we pull off calling these "functions" and losing the table?  It just seems a bit pedantic to explicitly state how the function is being stored.  I realize there are size and opcode issues, so it's something to discuss.

### OCSParamArray
* Does this type even need to exist?  Seems like at most it should be a category of NSArray.

### OCSProperty
* Do all properties need bounds?  Seems brittle to have them be optional but having the limits as accessible properties.  Adam loves the bounds for sliders, so it's an important feature to get right.

### OCSReverbSixParallelComb
* Doesn't follow any of the current OCS guidelines.
* This raises the question of how descriptive a class name should be.  Do we gain much from it named like this? NReverb seems better in a way.  It at least benefits from history.

### OCSFilterLowPassButterworth
* Doesn't follow any of the current OCS guidelines.

### OCSSegmentArray
* Question for Adam: Isn't linseg a subset of linsegr with both parameters as zero?  Would clean up the code a little.

### OCSWindowsTable
* Need to review with both of us what is happening with negative types and maximum value.


Current naming inconsistencies
==============================

##### Class naming - adjective before or after?
We need to decide on whether we adopt a style of adjective-before-the-noun or adjective-after-the-noun style.  The benefit of placing the adjective first is that you have greater readability.  The benefit of placing the adjective second is that you gain alphabet-proximity, so that documentation is automatically sorted correctly and code completion works from most general to most specific as you type.  

Example inconsistency:
	OCSFilterLowPassButterworth
vs. 
	OCSLowPassButterworthFilter

In the first example Filter is before its descriptors, but Low is in front of Pass. I don't think we can pull off adjective last consistently enough, so my inclination is that we group similar things in folders and Xcode and name them descriptively, meaning more English-y.  

##### Opcodes
Opcodes are one of the things that experienced Csound-ers know very well, so while we might like to ease their learning experience by keeping the names similar.  Often this will just mean to expand out the Csound opcode to remove abbreviation. `Foscili` could be `FMOscillator` for instance.  Where one opcode is clearly an improvement over an older one, the modifier text is unnecessary.  For instance the trailing i in `Oscili` did not encourage us to call the class `OscillatorWithInterpolation`