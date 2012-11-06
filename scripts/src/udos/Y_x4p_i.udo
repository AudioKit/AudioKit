/*
Y_x4p_i - Calcucaltes a Y value from a given X and 2 pairs of X/Y points, at init-time

DESCRIPTION
Performs a simple linear equation at init-time. The x-range is given by two points x1 and x2; the y-range by y1 and y2. The function returns the y value for a given x.
See the example below for a practical application (instr 1).

SYNTAX
iy Y_x4p_i ix, ix1, ix2, iy1, iy2

INITIALIZATION
ix1, iy1 - two points related to each other
ix2, iy2 - two other points related to each other
ix - another x value
iy - y value related to ix

CREDITS
joachim heintz 2011
*/

  opcode Y_x4p_i, i, iiiii
ix, ix1, ix2, iy1, iy2 xin
imm       =         (iy2-iy1) / (ix2-ix1)
inn       =         iy1 - imm*ix1
iy        =         imm*ix + inn
          xout      iy
  endop
 
