/*
 * TBVCF
 *
 * This code has been extracted from the Csound opcode "tbvcf".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Hans Mikelson
 * Year: 2000
 * Location: Opcodes/biquad.c
 *
 */


#include <math.h>
#include <stdint.h>
#include <stdlib.h>
#define ROOT2 (1.4142135623730950488)

#ifndef M_PI
#define M_PI		3.14159265358979323846	/* pi */
#endif

#include "soundpipe.h"

int sp_tbvcf_create(sp_tbvcf **p)
{
    *p = malloc(sizeof(sp_tbvcf));
    return SP_OK;
}

int sp_tbvcf_destroy(sp_tbvcf **p)
{
    free(*p);
    return SP_OK;
}

int sp_tbvcf_init(sp_data *sp, sp_tbvcf *p)
{
    p->fco = 500.0;
    p->res = 0.8;
    p->dist = 2.0;
    p->asym = 0.5;

    p->sr = sp->sr;
    p->onedsr = 1.0 / p->sr;

    p->iskip = 0.0;
    if(p->iskip == 0.0){
        p->y = p->y1 = p->y2 = 0.0;
    }
    p->fcocod = p->fco;
    p->rezcod = p->res;


    return SP_OK;
}

/* TODO: clean up code here. */
int sp_tbvcf_compute(sp_data *sp, sp_tbvcf *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT x;
    SPFLOAT fco, res, dist, asym;
    SPFLOAT y = p->y, y1 = p->y1, y2 = p->y2;
    /* The initialisations are fake to fool compiler warnings */
    SPFLOAT ih, fdbk, d, ad;
    SPFLOAT fc=0.0, fco1=0.0, q=0.0, q1=0.0;

    ih  = 0.001; /* ih is the incremental factor */

 /* Set up the pointers
    fcoptr  = p->fco;
    resptr  = p->res;
    distptr = p->dist;
    asymptr = p->asym; */

 /* Get the values for the k-rate variables
    fco  = (SPFLOAT)*fcoptr;
    res  = (SPFLOAT)*resptr;
    dist = (SPFLOAT)*distptr;
    asym = (SPFLOAT)*asymptr; */

    /* This should work in sp world */
    fco = p->fco;
    res = p->res;
    dist = p->dist;
    asym = p->asym;

 /* Try to decouple the variables */
    if ((p->rezcod==0) && (p->fcocod==0)) { /* Calc once only */
        q1   = res/(1.0 + sqrt(dist));
        fco1 = pow(fco*260.0/(1.0+q1*0.5),0.58);
        q    = q1*fco1*fco1*0.0005;
        fc   = fco1*p->onedsr*(p->sr/8.0);
    }
    if ((p->rezcod!=0) || (p->fcocod!=0)) {
        q1  = res/(1.0 + sqrt(dist));
        fco1 = pow(fco*260.0/(1.0+q1*0.5),0.58);
        q  = q1*fco1*fco1*0.0005;
        fc  = fco1*p->onedsr*(p->sr/8.0);
    }
    x  = *in;
    fdbk = q*y/(1.0 + exp(-3.0*y)*asym);
    y1  = y1 + ih*((x - y1)*fc - fdbk);
    d  = -0.1*y*20.0;
    ad  = (d*d*d + y2)*100.0*dist;
    y2  = y2 + ih*((y1 - y2)*fc + ad);
    y  = y + ih*((y2 - y)*fc);
    *out = (y*fc/1000.0*(1.0 + q1)*3.2);

    p->y = y; p->y1 = y1; p->y2 = y2;
    return SP_OK;
}
