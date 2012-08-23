    opcode PitchShifter, aa, aakkk
    
aL, aR, kpitch, kfine, kfeedback xin 
            setksmps    64
ifftsize    =           1024
ihopsize    =           256
kscal       =           octave((int(kpitch)/12)+kfine)

aOutL       init        0		
aOutR       init        0

fsig1L      pvsanal     aL + (aOutL * kfeedback), ifftsize, ihopsize, ifftsize, 0
fsig1R      pvsanal     aR + (aOutR * kfeedback), ifftsize, ihopsize, ifftsize, 0
fsig2L      pvscale     fsig1L, kscal
fsig2R      pvscale     fsig1R, kscal
aOutL       pvsynth     fsig2L
aOutR       pvsynth     fsig2R

            xout        aOutL, aOutR
    endop