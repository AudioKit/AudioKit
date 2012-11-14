<CsoundSynthesizer>
<CsInstruments>


sr	 =	44100 
ksmps	=	100 
nchnls	=	2 

gkgain	init	1 


; an opcode that calls itself recursively to update the graphs 
opcode updateGraphs, 0, iii 

        istartCh, ioffset, ifn xin 

        if (istartCh < 24) then 
                kamp	init	0 
                ksig table istartCh, ifn 
                kamp port	ksig/gkgain, .02 

                outvalue istartCh+ioffset, kamp 
                updateGraphs istartCh + 1, ioffset, ifn 
        endif 

endop 

instr 1	
        inbins	=	128 
        ifftsize	=	256 

        ; make ftables 
        iampfl	ftgen	0,0,inbins, 2, 0         
        iampfr	ftgen	0,0,inbins, 2, 0 
        ifiltfl	ftgen	0,0,inbins, 7, .5, inbins, .5 
        ifiltfr	ftgen	0,0,inbins, 7, .5, inbins, .5 

;	a1, a2	ins 
a1,	a2	soundin	"cg.wav" 

        ; read the eq params 
        keq	invalue "eq1" 
                tablew	keq, 3, ifiltfl 



        ; analyse and write to ftables 
        fsigl pvsanal a1, ifftsize, ifftsize/2, ifftsize, 0 
        kflagl pvsftw fsigl, iampfl	
        
        fsigr pvsanal a2, ifftsize, ifftsize/2, ifftsize, 0 
        kflagr pvsftw fsigr, iampfr 


        if (kflagl != 0) then 
                ; apply eq 
                keq invalue "eql1" 
                kval table 0, iampfl 
                        tablew	keq*kval,0,iampfl 
                kval table 1, iampfl 
                        tablew	keq*kval,1,iampfl 
                kval table 2, iampfl 
                        tablew	keq*kval,2,iampfl 
                kval table 3, iampfl 
                        tablew	keq*kval,3,iampfl 

                keq invalue "eql2" 
                kval table 4, iampfl 
                        tablew	keq*kval,4,iampfl 
                kval table 5, iampfl 
                        tablew	keq*kval,5,iampfl 
                kval table 6, iampfl 
                        tablew	keq*kval,6,iampfl 
                kval table 7, iampfl 
                        tablew	keq*kval,7,iampfl 

                keq invalue "eql3" 
                kval table 8, iampfl 
                        tablew	keq*kval,8,iampfl 
                kval table 9, iampfl 
                        tablew	keq*kval,9,iampfl 
                kval table 10, iampfl 
                        tablew	keq*kval,10,iampfl 
                kval table 11, iampfl 
                        tablew	keq*kval,11,iampfl 

                keq invalue "eql4" 
                kval table 12, iampfl 
                        tablew	keq*kval,12,iampfl 
                kval table 13, iampfl 
                        tablew	keq*kval,13,iampfl 
                kval table 14, iampfl 
                        tablew	keq*kval,14,iampfl 
                kval table 15, iampfl 
                        tablew	keq*kval,15,iampfl 

                keq invalue "eql5" 
                kval table 16, iampfl 
                        tablew	keq*kval,16,iampfl 
                kval table 17, iampfl 
                        tablew	keq*kval,17,iampfl 
                kval table 18, iampfl 
                        tablew	keq*kval,18,iampfl 
                kval table 19, iampfl 
                        tablew	keq*kval,19,iampfl 

                keq invalue "eql6" 
                kval table 20, iampfl 
                        tablew	keq*kval,20,iampfl 
                kval table 21, iampfl 
                        tablew	keq*kval,21,iampfl 
                kval table 22, iampfl 
                        tablew	keq*kval,22,iampfl 
                kval table 23, iampfl 
                        tablew	keq*kval,23,iampfl 

                ; update graphs 
                gkgain	invalue "gain" 
                updateGraphs 0, 0, iampfl 


                ; resynthesize	
                pvsftr      fsigl, iampfl 
        endif 

        if (kflagr != 0) then 
                ; apply eq 
                keq invalue "eqr1" 
                kval table 0, iampfr 
                        tablew	keq*kval,0,iampfr 
                kval table 1, iampfr 
                        tablew	keq*kval,1,iampfr 
                kval table 2, iampfr 
                        tablew	keq*kval,2,iampfr 
                kval table 3, iampfr 
                        tablew	keq*kval,3,iampfr 

                keq invalue "eqr2" 
                kval table 4, iampfr 
                        tablew	keq*kval,4,iampfr 
                kval table 5, iampfr 
                        tablew	keq*kval,5,iampfr 
                kval table 6, iampfr 
                        tablew	keq*kval,6,iampfr 
                kval table 7, iampfr 
                        tablew	keq*kval,7,iampfr 

                keq invalue "eqr3" 
                kval table 8, iampfr 
                        tablew	keq*kval,8,iampfr 
                kval table 9, iampfr 
                        tablew	keq*kval,9,iampfr 
                kval table 10, iampfr 
                        tablew	keq*kval,10,iampfr 
                kval table 11, iampfr 
                        tablew	keq*kval,11,iampfr 

                keq invalue "eqr4" 
                kval table 12, iampfr 
                        tablew	keq*kval,12,iampfr 
                kval table 13, iampfr 
                        tablew	keq*kval,13,iampfr 
                kval table 14, iampfr 
                        tablew	keq*kval,14,iampfr 
                kval table 15, iampfr 
                        tablew	keq*kval,15,iampfr 

                keq invalue "eqr5" 
                kval table 16, iampfr 
                        tablew	keq*kval,16,iampfr 
                kval table 17, iampfr 
                        tablew	keq*kval,17,iampfr 
                kval table 18, iampfr 
                        tablew	keq*kval,18,iampfr 
                kval table 19, iampfr 
                        tablew	keq*kval,19,iampfr 

                keq invalue "eqr6" 
                kval table 20, iampfr 
                        tablew	keq*kval,20,iampfr 
                kval table 21, iampfr 
                        tablew	keq*kval,21,iampfr 
                kval table 22, iampfr 
                        tablew	keq*kval,22,iampfr 
                kval table 23, iampfr 
                        tablew	keq*kval,23,iampfr 

                ; update graphs 
                updateGraphs 0, 24, iampfr 

                ; resynthesize	
                pvsftr      fsigr, iampfr 
        endif 


        aoutl  pvsynth   fsigl 
        aoutr  pvsynth   fsigr 
        outs aoutr, aoutr 
endin 
</CsInstruments>
<CsScore>
f1 0 512 10 1 
i1	0	9999 
</CsScore>

</CsoundSynthesizer>
<MacOptions>
Version: 3 
Render: Real 
Ask: Yes 
Functions: None 
Listing: Window 
WindowBounds: 2 46 1438 954 
CurrentView: orc 
IOViewEdit: Off 
Options: -b256 -A -s -m167 -R 
</MacOptions>
<MacGUI>
ioView background {18385, 18385, 18385} 
ioText {459, 128} {281, 193} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {11565, 10353, 11262} background border 
ioText {114, 128} {287, 194} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {11565, 10353, 11262} background border 
ioMeter {165, 140} {18, 169} {44563, 53738, 65535} "4" 1.686466 "4" 1.686466 fill 1 0 notrack 
ioMeter {132, 140} {18, 169} {44563, 53738, 65535} "1" 3.770600 "1" 3.770600 fill 1 0 notrack 
ioMeter {154, 140} {18, 169} {44563, 53738, 65535} "3" 3.170637 "3" 3.170637 fill 1 0 notrack 
ioMeter {143, 140} {18, 169} {44563, 53738, 65535} "2" 5.179554 "2" 5.179554 fill 1 0 notrack 
ioMeter {176, 140} {18, 169} {44563, 53738, 65535} "5" 1.326008 "5" 1.326008 fill 1 0 notrack 
ioMeter {187, 140} {18, 169} {44563, 53738, 65535} "6" 0.554654 "6" 0.554654 fill 1 0 notrack 
ioMeter {253, 140} {18, 169} {44563, 53738, 65535} "12" 0.356693 "12" 0.356693 fill 1 0 notrack 
ioMeter {231, 140} {18, 169} {44563, 53738, 65535} "10" 0.646967 "10" 0.646967 fill 1 0 notrack 
ioMeter {242, 140} {18, 169} {44563, 53738, 65535} "11" 0.804420 "11" 0.804420 fill 1 0 notrack 
ioMeter {220, 140} {18, 169} {44563, 53738, 65535} "9" 0.975366 "9" 0.975366 fill 1 0 notrack 
ioMeter {198, 140} {18, 169} {44563, 53738, 65535} "7" 0.552458 "7" 0.552458 fill 1 0 notrack 
ioMeter {209, 140} {18, 169} {44563, 53738, 65535} "8" 0.645465 "8" 0.645465 fill 1 0 notrack 
ioSlider {413, 129} {34, 192} 2000.000000 50.000000 2000.000000 gain 
ioMeter {121, 140} {18, 169} {44563, 53738, 65535} "0" 1.611575 "0" 1.611575 fill 1 0 notrack 
ioMeter {363, 140} {18, 169} {44563, 53738, 65535} "22" 0.539638 "22" 0.539638 fill 1 0 notrack 
ioMeter {374, 140} {18, 169} {44563, 53738, 65535} "23" 0.563197 "23" 0.563197 fill 1 0 notrack 
ioMeter {352, 140} {18, 169} {44563, 53738, 65535} "21" 0.257284 "21" 0.257284 fill 1 0 notrack 
ioMeter {341, 140} {18, 169} {44563, 53738, 65535} "20" 0.281900 "20" 0.281900 fill 1 0 notrack 
ioMeter {319, 140} {18, 169} {44563, 53738, 65535} "18" 0.779181 "18" 0.779181 fill 1 0 notrack 
ioMeter {330, 140} {18, 169} {44563, 53738, 65535} "19" 0.259022 "19" 0.259022 fill 1 0 notrack 
ioMeter {297, 140} {18, 169} {44563, 53738, 65535} "16" 1.256599 "16" 1.256599 fill 1 0 notrack 
ioMeter {308, 140} {18, 169} {44563, 53738, 65535} "17" 0.517030 "17" 0.517030 fill 1 0 notrack 
ioMeter {286, 140} {18, 169} {44563, 53738, 65535} "15" 1.104429 "15" 1.104429 fill 1 0 notrack 
ioMeter {275, 140} {18, 169} {44563, 53738, 65535} "14" 0.452940 "14" 0.452940 fill 1 0 notrack 
ioMeter {264, 140} {18, 169} {44563, 53738, 65535} "13" 0.509867 "13" 0.509867 fill 1 0 notrack 
ioMeter {717, 141} {18, 169} {44563, 53738, 65535} "47" 0.126801 "47" 0.126801 fill 1 0 notrack 
ioMeter {706, 141} {18, 169} {44563, 53738, 65535} "46" 0.229890 "46" 0.229890 fill 1 0 notrack 
ioMeter {695, 141} {18, 169} {44563, 53738, 65535} "45" 0.416281 "45" 0.416281 fill 1 0 notrack 
ioMeter {684, 141} {18, 169} {44563, 53738, 65535} "44" 0.448816 "44" 0.448816 fill 1 0 notrack 
ioMeter {673, 141} {18, 169} {44563, 53738, 65535} "43" 0.189115 "43" 0.189115 fill 1 0 notrack 
ioMeter {651, 141} {18, 169} {44563, 53738, 65535} "41" 0.589724 "41" 0.589724 fill 1 0 notrack 
ioMeter {662, 141} {18, 169} {44563, 53738, 65535} "42" 0.128532 "42" 0.128532 fill 1 0 notrack 
ioMeter {629, 141} {18, 169} {44563, 53738, 65535} "39" 0.827556 "39" 0.827556 fill 1 0 notrack 
ioMeter {640, 141} {18, 169} {44563, 53738, 65535} "40" 1.240141 "40" 1.240141 fill 1 0 notrack 
ioMeter {618, 141} {18, 169} {44563, 53738, 65535} "38" 0.657224 "38" 0.657224 fill 1 0 notrack 
ioMeter {585, 141} {18, 169} {44563, 53738, 65535} "35" 0.829597 "35" 0.829597 fill 1 0 notrack 
ioMeter {563, 141} {18, 169} {44563, 53738, 65535} "33" 0.844676 "33" 0.844676 fill 1 0 notrack 
ioMeter {574, 141} {18, 169} {44563, 53738, 65535} "34" 0.768161 "34" 0.768161 fill 1 0 notrack 
ioMeter {607, 141} {18, 169} {44563, 53738, 65535} "37" 0.613079 "37" 0.613079 fill 1 0 notrack 
ioMeter {596, 141} {18, 169} {44563, 53738, 65535} "36" 0.444865 "36" 0.444865 fill 1 0 notrack 
ioMeter {508, 141} {18, 169} {44563, 53738, 65535} "28" 0.925915 "28" 0.925915 fill 1 0 notrack 
ioMeter {519, 141} {18, 169} {44563, 53738, 65535} "29" 0.754115 "29" 0.754115 fill 1 0 notrack 
ioMeter {552, 141} {18, 169} {44563, 53738, 65535} "32" 0.589787 "32" 0.589787 fill 1 0 notrack 
ioMeter {530, 141} {18, 169} {44563, 53738, 65535} "30" 0.160768 "30" 0.160768 fill 1 0 notrack 
ioMeter {541, 141} {18, 169} {44563, 53738, 65535} "31" 0.342196 "31" 0.342196 fill 1 0 notrack 
ioMeter {497, 141} {18, 169} {44563, 53738, 65535} "27" 0.389064 "27" 0.389064 fill 1 0 notrack 
ioMeter {486, 141} {18, 169} {44563, 53738, 65535} "26" 0.347008 "26" 0.347008 fill 1 0 notrack 
ioMeter {475, 141} {18, 169} {44563, 53738, 65535} "25" 0.179151 "25" 0.179151 fill 1 0 notrack 
ioMeter {464, 141} {18, 169} {44563, 53738, 65535} "24" 0.089917 "24" 0.089917 fill 1 0 notrack 
ioKnob {300, 323} {48, 48} 0.000000 10.000000 0.100000 5.199999 eql5 
ioKnob {347, 323} {48, 48} 0.000000 10.000000 0.100000 5.199999 eql6 
ioKnob {253, 323} {48, 48} 0.000000 10.000000 0.100000 5.200001 eql4 
ioKnob {206, 323} {48, 48} 0.000000 10.000000 0.100000 4.899999 eql3 
ioKnob {159, 323} {48, 48} 0.000000 10.000000 0.100000 5.099998 eql2 
ioKnob {112, 323} {48, 48} 0.000000 10.000000 0.100000 5.099998 eql1 
ioKnob {642, 321} {48, 48} 0.000000 10.000000 0.100000 4.899999 eqr5 
ioKnob {689, 321} {48, 48} 0.000000 10.000000 0.100000 5.299998 eqr6 
ioKnob {595, 321} {48, 48} 0.000000 10.000000 0.100000 5.099998 eqr4 
ioKnob {548, 321} {48, 48} 0.000000 10.000000 0.100000 5.099998 eqr3 
ioKnob {501, 321} {48, 48} 0.000000 10.000000 0.100000 4.900000 eqr2 
ioKnob {454, 321} {48, 48} 0.000000 10.000000 0.100000 5.099999 eqr1 
</MacGUI>
