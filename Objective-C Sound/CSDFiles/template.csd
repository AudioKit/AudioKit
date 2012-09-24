<CsoundSynthesizer>

<CsOptions>
%@
</CsOptions>

<CsInstruments>

%@

; Deactivates a complete instrument
instr DeactivateInstrument
    turnoff2 p4, 0, 1
endin

; Event End or Note Off
instr DeactivateNote
    turnoff2 p4, 4, 1
endin

</CsInstruments>

<CsScore>
f0 10000000
</CsScore>

</CsoundSynthesizer>
