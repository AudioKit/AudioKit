/*
flexlinsegtable - Envelope UDO that reads from 1 to 31 parameters from a table.

DESCRIPTION
An envelope UDO that reads from 1 to 31 parameters from a table.  Use GEN02 to create your tables and it will automatically fill the rest of the table elements with 0.  eg.  f10 0 32 -2  0.0  0.1 1.0  0.1 0.7  0.8 0.0


SYNTAX
kenv  flexlinsegtable  iftablenum

INITIALIZATION
iftablenum is the number of a table containing the envelope parameters.  The table must be at least size 32.

PERFORMANCE
kenv is the output envelope.

CREDITS
Anthony Kozar, 2006
*/

opcode  flexlinsegtable, k, i
	iftablenum xin
	
	; I don't think using tb15() will cause a problem with using multiple
	; instances of this UDO since all of the table accesses happen at
	; init-time.  But be careful!  If you use tb15() in your own code,
	; it could be problematic.
	       tb15_init  iftablenum

	kenv   linseg	tb15(0), tb15(1), tb15(2), tb15(3), tb15(4), \
	                  tb15(5), tb15(6), tb15(7), tb15(8), tb15(9), \
	                  tb15(10), tb15(11), tb15(12), tb15(13), tb15(14), \
	                  tb15(15), tb15(16), tb15(17), tb15(18), tb15(19), \
	                  tb15(20), tb15(21), tb15(22), tb15(23), tb15(24), \
	                  tb15(25), tb15(26), tb15(27), tb15(28), tb15(29), \
				tb15(30)
	xout   kenv
endop

 
