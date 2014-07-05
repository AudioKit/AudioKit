    opcode Compressor, aa, aakkkk
    
aL, aR, kthresh, kratio, kattack, krel xin
klowknee    init 48
khighknee   init 60
ilook       init 0.050
aOutL       compress aL, aL, kthresh, klowknee, khighknee, kratio, kattack, krel, ilook
aOutR       compress aR, aR, kthresh, klowknee, khighknee, kratio, kattack, krel, ilook
            xout aOutL, aOutR
            
    endop