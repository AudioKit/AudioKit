/*
tieStatus - Returns the status of a note in a group of tied notes

DESCRIPTION
Determines if a note is a part of a group of tied notes, and if it is, return a number indicating if it is the first note, a middle note, or the last note of a group of tied notes. (Runs at i-time.)

Value Status
-1    This note is a stand-alone note and not a part of a group of tied notes
0     This note is the first note of a group of tied notes
1     This note is middle note within a group of tied notes
2     This note is an end note of a group of tied notes

SYNTAX
itiestatus tieStatus

CREDITS
Steven Yi
*/

	opcode tieStatus,i,0

itie tival

if (itie == 0 && p3 < 0) then
    ; this is an initial note within a group of tied notes
    itiestatus = 0
       
elseif (p3 < 0 && itie == 1) then
    ; this is a middle note within a group of tied notes 
    itiestatus = 1

elseif (p3 > 0 && itie == 1) then
    ; this is an end note out of a group of tied notes
    itiestatus = 2

elseif (p3 > 0 && itie == 0) then
    itiestatus = -1

endif  

	xout	itiestatus

	endop
 
