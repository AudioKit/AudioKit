/*
Baboon - UDO wrapper for the babo opcode

DESCRIPTION
Baboon is a full expert mode wrapper for the babo opcode, a physical model reverberator based on the work of David Rochesso.

SYNTAX
aL,aR Baboon idur,ixstart,iystart,izstart,ixend,iyend,izend,ixsize,iysize,izsize,idiff,idecay,ihidecay,irx,iry,irz,irdist,idirect,iearly,ain

INITIALIZATION
none

PERFORMANCE
aL,aR = babo left and right audio outputs
See the Csound manual for the babo opcode for details of each i-rate variable.

CREDITS
by Brian Wong, 2010
*/

opcode Baboon,aa,iiiiiiiiiiiiiiiiiiia
idur,ixstart,iystart,izstart,ixend,iyend,iznd,ixsize,iysize,izsize,idiff,idecay,ihidecay,irx,iry,irz,irdist,idirect,iearly,ain xin
ksource_x line    ixstart, idur, ixend
ksource_y line    iystart, idur, iyend
ksource_z line    izstart, idur, izend
iexpert ftgen 0, 0, 8, -2, idecay, ihidecay, irx, iry, irz, irdist, idirect, iearly
aL,aR     babo    ain, ksource_x, ksource_y, ksource_z, ixsize, iysize, izsize, idiff, iexpert
xout    aL,aR
 endop

 
