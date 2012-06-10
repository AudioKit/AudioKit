Objective-Csound
================

Potentially a very important part of the H4Y technology stack, Objective-Csound 
aims to eliminate the need for csd files and Csound-for-iOS hooks into code by 
representing every part of the Csound orchestra instruments as objects.  

TODO:
    
* Globals: Enhance CSDOrchestra to enable global outputs and instruments
* CSDAssignment & Expression: Develop a way to write math in the Csound realm
 Use these opcodes!: http://www.csounds.com/manual/html/MathOpeqfunc.html

REMINDERS:
* Create more opcodes
* Create More Function Table subclasses
* Develop examples

BUGS:

* Memory leak or something is breaking paramArrayFromParams

* Currently we have to double click when you use the menu to go to another
view, for some reason this will properly clear out the CSD file so that the 
sound appears properly.

NOTES:

* Discuss with eachother what it means to have an output at audio rate or control rate
  ie. Does each type of output just get its own instance variable, or are the input
  and output signatures differing enough to justify different opcode classes
  e.g. Oscillator and OscillatingController?
  
  -ARB - one of the nice things about csound is that it elegantly does not make this distinction.
  An oscillator after all is a pointer moving through a table at a given rate, or many other 
  more mathematical interpretations that aren't really about audio at all.  As 
  one begins to use oscillators for their "sine wave" audio properties (sounds like), or as control functions
  (behaves like), or just for the math (functions like), this begets some kind of "real" understanding of what an oscillator is.
  
  -AOP - that's a good point.  I'll have to digest what it means to Objective-Csound and us.
  Clearly, we want to be even more about the understanding than csound alone is.
  
* Should think about standardizing the headers of the files.  I don't care much who 
wrote the file initially or when it was created.  To me that's all handled much 
better by the code repository, although I suppose if we create a new fresh repo at 
some point, then all is lost.

* Consider including expected units in method signatures if not CSDParam

* CSDOscillator keeps a reference to NSString *output and sets it during init. 
convertToCSD looks for *output as an argument sent to the formatter.  
CSDFoscili just doesn't have an ivar output and just uses "foscili" directly 
in the formatter of convertToCsd.  Do we want to keep a reference to output for 
comparison?  Maybe an enum at CSDConstants of all the available opcode types 
would be simpler for comparison and whatnot.

* Adding unit generators: is there an elegant way to generate a%, k%, and i% 
prefixes for output assignments (and their subsequent re-use in paramteres of 
other opcodes)? Ideally, an objective-csound user would set something like 
an (BOOL)audioRate flag and everything would be set for them when converting 
to csd, but this causes a problem when user wants to re-enter the output in 
the init argument of a newly created opcdode.

* making a,k,i assignments behind the scenes as part of scripting opcode id's 
and output generation is essential.  As I was making unitgen example, my output 
was a string set to "aSomething" and I was trying to plug the opcode into 
parameters that only took k.  The result was silence.  This should all be under 
the hood and automated after specifying the rate for an opcdoe and knowing what 
kind of affordances a parameter has by seeing its fastest subclass of CSDParam 
on autocomplete.  This also means that if something can take, a,k, OR i rate 
and the autocomplete says CSDParamA, then the it may also need to handle a 
CSDParamK object passed as argument. 

RECENT UPDATE NOTES:
* if wanting to set CSDParam to pValue corresponding to a note's duration, 
the pfield will always be 3.  Should be a final constant variable to hide 
the p-field number from the objective-c user.  However, by making a 
CSDConstant typedef of type PValueReservedTag, we reinforce how users should 
stylistically create typedefs with this naming convention for their variable 
p-fields kPValueTagSomething
