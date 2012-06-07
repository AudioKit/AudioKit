Objective-Csound
================

Potentially a very important part of the H4Y technology stack, Objective-Csound 
aims to eliminate the need for csd files and Csound-for-iOS hooks into code by 
representing every part of the Csound orchestra instruments as objects.  

TODO:

* Set up Function Tables as subclasses a la CSDOpcodes
* Create more opcodes
* Develop examples

Questions:

* Although it's uncommon to have an fStatement as a p-Value, I believe it is 
legal, so should we be treating FunctionStatements as CSDParams also?

* Should there be subclasses of CSDParam as well?  That would allow us to have more 
informative signatures.