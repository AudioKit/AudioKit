/*
Y_x4p_k - Calcucaltes a Y value from a given X and 2 pairs of X/Y points, at k-time

DESCRIPTION
Performs a simple linear equation at k-time. The x-range is given by two points x1 and x2; the y-range by y1 and y2. The function returns the y value for a given x.
See the example below for a practical application (instr 2).

SYNTAX
ky Y_x4p_k kx, kx1, kx2, ky1, ky2

PERFORMANCE
kx1, ky1 - two points related to each other
kx2, ky2 - two other points related to each other
kx - another x value
ky - y value related to ix

CREDITS
joachim heintz 2011
*/

  opcode Y_x4p_k, k, kkkkk
kx, kx1, kx2, ky1, ky2 xin
kmm       =         (ky2-ky1) / (kx2-kx1)
knn       =         ky1 - kmm*kx1
ky        =         kmm*kx + knn
          xout      ky
  endop
 
