Developer's Guide
=================

### Documentation Instructions

We use appledoc to create Apple-style documentation and Quick Help from within Xcode.

http://gentlebytes.com/appledoc/

After installation, use this command to run documentation generator:

    appledoc --project-name Objective-Csound \\
    --project-company "Hear For Yourself" \\
    --company-id com.hearforyourself \\
    --no-repeat-first-par \\
    --output ~/help \\
    .

Documentation will be automatically reloaded in Xcode, but Quick Help will not be updated until you manually restart Xcode.

Since appledoc uses file comments to generate the documentation, engaging in good, consistent commenting habits is essential. 

### Header (.h) files

#### Default top-of-file comments
The default Apple comments are fine, except that the project name should be replaced with "Objective-Csound".

#### Import lines
Only import what is necessary for the .h file to run, not everything that the implementation file may need.

##### Description Comment
The paragraph of this first comment block defines the *Abstract* in Apple Quick Help.  This paragraph plus the rest defines the *Overview* section of the class reference document.

#### Instance variables
Avoid declaring instance variables in the header file unless necessary for subclasses.

#### Properties
Properties should be commented with the appledoc standard.  Property names should be descriptive.  

#### Methods
Methods should also be fully commented to the appledoc standard which includes @param lines for every parameter sent to the method.  These parameters should be named very similarly to the method signature text that precedes them so that the display from Quick Help is clear.  

For example:
	initWithFrequency:(OCSParam *)frequency
not 
	initWithFrequency:(OCSParam *)f

Long signatures should be broken over lines.  Some variable names such as `in` should be avoided because they break Xcode's indenting.

Although it may be tempting to create the methods in an order identical to Csound's parameters, consider also the order of importance of the parameters.  Note that the Csound documentation usually starts witht the initialization parameters and then the performance parameters.  This makes good sense especially since our instantiation methods start with "init".  

We support two ways of using opcodes.

a) Any init function should specify everything that is required for an opcode to run.  Using the initWithXXX method should try to ensure that the developer will see everything she needs to populate in order to create a working opcode.

b) The problem with the first method is that it can look unwieldy.  So, if the developer prefers, she should be able to alloc-init the class without any parameters and define parameters after the fact as properties. The developer is on her own to debug the CSD file, especially looking for (null)s when underspecifying the opcode. 

### Implementation (.m) files
Since implementation files are not used in creating documentation, there are fewer rules and conventions to follow. As in header files, the default Apple comments are fine, except that the project name should be replaced with "Objective-Csound" and you import lines should always be minimized.

### Naming Conventions
Variables names and method signatures should be very descriptive without going overboard.    

One of the primary ways Objective-Csound differs from Csound philosophically is that OCS embraces verbosity while Csound embraces brevity.  But because we're a part of the Csound community and ecosystem of tools, and Csound has such a rich history, we try to keep as much of the terminology consistent. 

#### Current naming inconsistencies

##### Class naming - adjective before or after?
We need to decide on whether we adopt a style of adjective-before-the-noun or adjective-after-the-noun style.  The benefit of placing the adjective first is that you have greater readability.  The benefit of placing the adjective second is that you gain alphabet-proximity, so that documentation is automatically sorted correctly and code completion works from most general to most specific as you type.  

Example inconsistency:
	OCSAudio
vs. 
	OCSLoopingOscillator
 
My inclination is that we group similar things in folders and Xcode and name them descriptively, meaning more English-y.  So looping oscillator stay and stero ouput needs renaming.

##### Opcodes
Opcodes are one of the things that experienced Csound-ers know very well, so while we might like to ease their learning experience by keeping the names similar.  Often this will just mean to expand out the Csound opcode to remove abbreviation. `Foscili` could be `FMOscillator` for instance.  Where one opcode is clearly an improvement over an older one, the modifier text is unnecessary.  For instance the trailing i in `Oscili` did not encourage us to call the class `OscillatorWithInterpolation`


