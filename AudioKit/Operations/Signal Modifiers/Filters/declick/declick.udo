/*
declick - removes clicks from signal start and end

DESCRIPTION
Given a signal, declick will apply an envelope to ensure there is no clicking at the start or end of the sound.

(Taken from the Csound Reference Manual)

SYNTAX
aout    declick    ain

PERFORMANCE
ain - signal to declick
aout - declicked signal

CREDITS
Author: Istvan Varga
*/

        opcode declick, a, a

ain     xin
aenv    linseg 0, 0.02, 1, p3 - 0.05, 1, 0.02, 0, 0.01, 0
        xout ain * aenv         ; apply envelope and write output

        endop
 