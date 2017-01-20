/*
 * Dist
 * 
 * This code has been extracted from the Csound opcode "distort1".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Hans Mikelson
 * Year: 1998
 * Location: Opcodes/biquad.c
 *
 */

#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"

int sp_dist_create(sp_dist **p)
{
    *p = malloc(sizeof(sp_dist));
    return SP_OK;
}

int sp_dist_destroy(sp_dist **p)
{
    free(*p);
    return SP_OK;
}

int sp_dist_init(sp_data *sp, sp_dist *p)
{
    p->pregain = 2.0;
    p->postgain = 0.5;
    p->shape1 = 0;
    p->shape2 = 0;
    return SP_OK;
}

int sp_dist_compute(sp_data *sp, sp_dist *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT pregain = p->pregain, postgain  = p->postgain;
    SPFLOAT shape1 = p->shape1, shape2 = p->shape2;
    SPFLOAT sig;
    
    pregain   *=  6.5536;
    postgain  *=  0.61035156;
    shape1    *=  4.096;
    shape2    *=  4.096;

    /* IV - Dec 28 2002 */
    shape1 += pregain;
    shape2 -= pregain;
    postgain *= 0.5;
    sig = *in;
    /* Generate tanh distortion and output the result */
    *out =                          
    ((exp(sig * shape1) - exp(sig * shape2))
             / cosh(sig * pregain))
    * postgain;
    return SP_OK;
}
