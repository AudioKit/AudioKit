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
Properties should be commented with the appledoc standard.  Property names should be descriptive.  Every input parameter should be a property as well as part

#### Methods
Methods should also be fully commented to the appledoc standard which includes @param lines for every parameter sent to the method.  These parameters should be named very similarly to the method signature text that precedes them so that the display from Quick Help is clear.  

For example:
	initWithFrequency:(OCSParameter *)frequency
not 
	initWithFrequency:(OCSParameter *)f

Long signatures should be broken over lines.  Some variable names such as `in` should be avoided because they break Xcode's indenting.

Although it may be tempting to create the methods in an order identical to Csound's parameters, consider also the order of importance of the parameters.  Note that the Csound documentation usually starts witht the initialization parameters and then the performance parameters.  This makes good sense especially since our instantiation methods start with "init".  

We support two ways of using opcodes.

a) Any init function should specify everything that is required for an opcode to run.  Using the initWithXXX method should try to ensure that the developer will see everything she needs to populate in order to create a working opcode.

b) The problem with the first method is that it can look unwieldy.  So, if the developer prefers, she should be able to alloc-init the class without any parameters and define parameters after the fact as properties. The developer is on her own to debug the CSD file, especially looking for (null)s when underspecifying the opcode. 

### Implementation (.m) files
As in header files, the default Apple comments are fine, except that the project name should be replaced with "Objective-Csound" and your import lines should always be minimized.  Inside of implmentation files is where things should look "Csound-y" meaning that the original opcode names appear and you should use the short variable names from the Csounds.com manual.

### Naming Conventions
Variables names and method signatures should be very descriptive without going overboard.  Everything in Objective-Csound should aim to be adjective-first naming.  For example this means we would write "OCSLinearEnvelope" not "OCSEnvelopeLinear." The reason for this is because we want to make everything as clear as possible in English.  The argument that you want to group similar things alphabetically is valid, but in practice it is very hard to achieve unilaterally.  

One of the primary ways Objective-Csound differs from Csound philosophically is that OCS embraces verbosity while Csound embraces brevity.  But because we're a part of the Csound community and ecosystem of tools, and Csound has such a rich history, we try to keep as much of the terminology consistent as we can.

Opcodes are one of the things that experienced Csound-ers know very well, so we ease their learning experience by keeping the names similar.  Often this will just mean to expand out the Csound opcode to remove abbreviation. `Foscili` becomes `FMOscillator` for instance.  Where one opcode is clearly an improvement over an older one, the modifier text is unnecessary.  For instance the trailing i in `Fpscili` did not encourage us to call the class `FMOscillatorWithInterpolation`




