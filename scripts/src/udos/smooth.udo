/*
smooth - smooths k-rate MIDI-controlled signals

SYNTAX
kin smooth kin

CREDITS
Coded by Iain McCurdy, Implemented as a UDO by Jonathan Murphy
*/

    opcode smooth, k, k

  kin       xin
  kport	    linseg    0, 0.0001, 0.01, 1, 0.01
  kin       portk     kin, kport
            xout      kin

    endop
 
