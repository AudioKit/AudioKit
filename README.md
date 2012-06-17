Objective-Csound
================

Potentially a very important part of the H4Y technology stack, Objective-Csound 
aims to eliminate the need for csd files and Csound-for-iOS hooks into code by 
representing every part of the Csound orchestra instruments as objects.  

TODO:

* Create a grain instrument to further test gen01 and ftgentmp
* Make a MIDI module that makes more sense than Csound's current midi implementation / Disconnect UIWidgets
* Create more opcodes (fix up CSDPluck)
* Create More Function Table subclasses
* Develop better examples
* Minimize #import statements - I think we have too many unneeded ones in some files

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
  But I don't think we lose that necessarily by having a very similar named class.
  
* Should think about standardizing the headers of the files.  I don't care much who 
wrote the file initially or when it was created.  To me that's all handled much 
better by the code repository, although I suppose if we create a new fresh repo at 
some point, then all is lost.

* Consider including expected units in method signatures if not CSDParam.  For instance, when
making the vibrato oscillator example I needed to know whether amplitude was a or k-rate.  The 
class had CSDParam as the argument type which I assumed was a-rate, but it turns out oscil only accepts k and slower.