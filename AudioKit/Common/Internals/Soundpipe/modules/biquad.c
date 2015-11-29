/*
 * Biquad
 * 
 * This code has been extracted from the Csound opcode "biquad".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Hans Mikelson 
 * Year: 1998
 * Location: Opcodes/biquad.c
 *
 */

#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846	
#endif 

int sp_biquad_create(sp_biquad **p)
{
    *p = malloc(sizeof(sp_biquad));
    return SP_OK;
}

int sp_biquad_destroy(sp_biquad **p)
{
    free(*p);
    return SP_OK;
}

int sp_biquad_init(sp_data *sp, sp_biquad *p)
{
    p->tpidsr = 2.0*M_PI / sp->sr;
    p->sr = sp->sr;

    p->cutoff = 500;
    p->res = 0.7;
    p->reinit = 0.0;

    SPFLOAT fcon = p->cutoff * p->tpidsr;
    SPFLOAT alpha = 1-2*p->res*cos(fcon)*cos(fcon)+p->res*p->res*cos(2*fcon);
    SPFLOAT beta = p->res*p->res*sin(2*fcon)-2*p->res*cos(fcon)*sin(fcon);
    SPFLOAT gamma = 1+cos(fcon);
    SPFLOAT m1 = alpha*gamma+beta*sin(fcon);
    SPFLOAT m2 = alpha*gamma-beta*sin(fcon);
    SPFLOAT den = sqrt(m1*m1+m2*m2);

    p->b0 = 1.5*(alpha*alpha+beta*beta)/den;
    p->b1 = p->b0;
    p->b2 = 0.0;
    p->a0 = 1.0;
    p->a1 = -2.0*p->res*cos(fcon);
    p->a2 = p->res*p->res;


   if(p->reinit == 0.0){
      p->xnm1 = p->xnm2 = p->ynm1 = p->ynm2 = 0.0;
   }
   return SP_OK; 
}

int sp_biquad_compute(sp_data *sp, sp_biquad *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT xn, yn;
    SPFLOAT a0 = p->a0, a1 = p->a1, a2 = p->a2;
    SPFLOAT b0 = p->b0, b1 = p->b1, b2 = p->b2;
    SPFLOAT xnm1 = p->xnm1, xnm2 = p->xnm2, ynm1 = p->ynm1, ynm2 = p->ynm2;

    xn = *in;
    yn = ( b0 * xn + b1 * xnm1 + b2 * xnm2 -
             a1 * ynm1 - a2 * ynm2) / a0;
    xnm2 = xnm1;
    xnm1 = xn;
    ynm2 = ynm1;
    ynm1 = yn;
    *out = yn;
    
    p->xnm1 = xnm1; p->xnm2 = xnm2; p->ynm1 = ynm1; p->ynm2 = ynm2;
    return SP_OK;
}
