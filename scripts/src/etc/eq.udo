;inumbins should be 8192 for a 31 band EQ 
;iampin is the input amplitude table (use pvsftw to read the pvs   
signal amplitudes to a table) 
;aimpout is the output table which should be later multiplied with the   
amplitude of the original pvs signal (I use pvsfilter) 
;iamptable is the input table containing an EQ function it should   
contain 32 indexes (e.g. "giamptable	 ftgen 103,0,32,-7,1,32, 1"). 

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