<CsoundSynthesizer> 
<CsOptions> 
</CsOptions> 
<CsInstruments> 
sr=96000 
ksmps=100 
nchnls=2 
0dbfs = 1 
giamptable	 ftgen 103,0,32,-7,1,32, 1 
giamptable2	ftgen 104,0,32,-7,1,32, 1 
giampin2 ftgen 0,0,8192,2,0 
giampout2 ftgen 1001,0,8192,2,0 
giampin22 ftgen 0,0,8192,2,0 
giampout22 ftgen 1002,0,8192,2,0 
giampin3	ftgen 0,0,8192,7,1,8192, 1 
giampin33	ftgen 0,0,8192,7,1,8192, 1 
giampout100	ftgen 200,0,64,-7,1,64, 1 
giampout101	ftgen 201,0,64,-7,1,64, 1 
opcode eq, 0, iiii 
inumbins, iampin, iampout, iamptable xin 
iclear ftgen 0, 0, inumbins, 2, 0 
tablecopy iampout, iclear 
kindex = 0 
kcount = 0 
kcount2 = kcount+1 
loop: 
;read eq tabe data for 3 consecutive bins at a time 
kmult	 table kindex, iamptable 
kmult1	 table kindex+1, iamptable 
kmult2	 table kindex+2, iamptable 
;Denormalization issue! 
kmult = kmult+0.00000000001 
kmult1= kmult1+0.00000000001 
kmult2= kmult2+0.00000000001 
;if less value is less than 0.0011 then set it to zero 
if (kmult < 0.001) then 
kmult = 0.00000000001 
endif 
if (kmult1 < 0.001) then 
kmult1 = 0.00000000001 
endif 
if (kmult2 < 0.001) then 
kmult2 = 0.00000000001 
endif 
;Write the values to the output table 
vadd iampout, kmult, kcount2, kcount 
vadd iampout, kmult1, kcount2, kcount+kcount2 
vadd iampout, kmult2, kcount2, kcount+(kcount2*2) 
kmax = kcount+(kcount2*2) 
kindex = kindex+3 
kcount = kcount+kcount2*3 
kcount2 = kcount2 * 2 
if (kmax < inumbins) kgoto loop 
endop 
opcode disp, 0, iiii 
inumbins, iampin, iampout, ioffset xin 
iclear ftgen 0, 0, inumbins, 2, 0 
tablecopy iampout, iclear 
kcount3 = ioffset 
ktest = 0 
kvalinit = 0 
kcount = 0 
kcount2 = 1 
kcountband = 0 
loop: 
kval	 table kcount, iampin 
kvalinit = kval+kvalinit 
kcount = kcount + 1 
kcountband = kcountband + 1 
if (kcountband == kcount2) kgoto contin 
kgoto loop 
contin: 
kcountband = 0 
ktest = ktest + 1 
kvalinit = kvalinit 
tablew kvalinit, kcount3, iampout 
kvalinit = 0 
kcount3 = kcount3+1 
if (ktest < 3) kgoto loop 
kgoto mult 
mult: 
ktest = 0 
kcount2 = kcount2*2 
if (kcount < inumbins) kgoto loop 
endop 
instr 1 
kdepth	chnget "depth" 
kdepth	port kdepth, 0.01 
ain1, ain2	ins 
ifftsize = p4 
iol = p5 
iNumBins = (ifftsize/2) + 1 
ihop = ifftsize/iol 
iwindow = ifftsize*p6 
fsig1 pvsanal ain1, ifftsize, ihop, iwindow, p7 
fsig2 pvsanal ain2, ifftsize, ihop, iwindow, p7 
fsdummy pvsinit ifftsize, ihop, iwindow, p7 
fsig7 pvsmix fsig1,fsdummy 
fsig8 pvsmix fsig2,fsdummy 
kflag2 pvsftw fsig1, giampin2 
if (kflag2 > 0) then ; only proc when frame is ready 
eq iNumBins, giampin2, giampout2, giamptable 
; read modified data back to fsrc 
pvsftr fsig1, giampout2 
endif 
kflag22 pvsftw fsig2, giampin22 
if (kflag22 > 0) then ; only proc when frame is ready 
eq iNumBins, giampin22, giampout22, giamptable2 
; read modified data back to fsrc 
pvsftr fsig2, giampout22 
endif 
fsig5 pvsfilter fsig7, fsig1, kdepth 
fsig6 pvsfilter fsig8, fsig2, kdepth 
kflag pvsftw fsig5, giampin3 
if (kflag > 0) then ; only proc when frame is ready 
disp iNumBins, giampin3, giampout100, 0 
endif 
kflag1 pvsftw fsig6, giampin33 
if (kflag1 > 0) then ; only proc when frame is ready 
disp iNumBins, giampin33, giampout101, 31 
endif 
aout1 pvsynth fsig5 
aout2 pvsynth fsig6 
outs aout1, aout2 
endin 
instr 2 
ftsave "./EQLog/EQ1.ftsave", 1, 1001 
ftsave "./EQLog/EQ2.ftsave", 1, 1002 
endin 
</CsInstruments> 
<CsScore> 
; Table #1, a sine wave. 
;f 1 0 16384 10 1 
f0 86400 
;i1 0 2 2048 2 2 0 
e 
</CsScore> 
</CsoundSynthesizer> 