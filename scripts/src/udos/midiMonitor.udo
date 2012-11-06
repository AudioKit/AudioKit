/*
midiMonitor - Displays midi channel and control number information

DESCRIPTION
This opcode displays incoming midi channel and control number information. 

SYNTAX
kdummy midiMonitor

INITIALIZATION
--none--

PERFORMANCE
This opcode outputs directly to the command line. Remember that in order to use this UDO one must specify the correct midi controller number by using the -Mn command line flag. If the correct controller number is not known pass -M99 and Csound will list the available devices. 

CREDITS
Rory Walsh, 2007
*/

opcode midiMonitor, k,o
kMidiSig = 0
kstatus, kchan, kdata1, kdata2 midiin
k1 changed kstatus
k2 changed kchan
k3 changed kdata1
k4 changed kdata2
if((k1==1)||(k2==1)||(k3==1)||(k4==1)) then
printks "Value:%d ChanNo:%d CtrlNo:%d\n" , 0, kdata2, kchan, kdata1  
kMidiSig = 1   
endif 
xout kMidiSig
endop


 
