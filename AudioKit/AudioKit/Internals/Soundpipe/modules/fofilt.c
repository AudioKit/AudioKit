/*
 * Fofilt
 *
 * This code has been extracted from the Csound opcode "fofilter".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Victor Lazzarini
 * Year: 2004
 * Location: Opcodes/newfils.c
 *
 */

#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif


int sp_fofilt_create(sp_fofilt **p)
{
    *p = malloc(sizeof(sp_fofilt));
    return SP_OK;
}

int sp_fofilt_destroy(sp_fofilt **p)
{
    free(*p);
    return SP_OK;
}

int sp_fofilt_init(sp_data *sp, sp_fofilt *p)
{
   p->tpidsr = 2.0*M_PI / sp->sr;
   p->sr = sp->sr;

   p->freq = 1000;
   p->atk = 0.007;
   p->dec = 0.04;
   p->istor = 0.0;

   int i;
   if (p->istor==0.0){
        for (i=0; i<4; i++)
         p->delay[i] = 0.0;
   }
   return SP_OK;
}

int sp_fofilt_compute(sp_data *sp, sp_fofilt *p, SPFLOAT *in, SPFLOAT *out)
{

    SPFLOAT freq = p->freq;
    SPFLOAT ris = p->atk;
    SPFLOAT dec = p->dec;
    SPFLOAT *delay = p->delay,ang=0,fsc,rrad1=0,rrad2=0;
    SPFLOAT w1,y1,w2,y2;
    SPFLOAT lfrq = -1.0, lrs = -1.0, ldc = -1.0;

    SPFLOAT frq = freq;
    SPFLOAT rs = ris;
    SPFLOAT dc = dec;
    if (frq != lfrq || rs != lrs || dc != ldc) {
        lfrq = frq; lrs = rs; ldc = dc;
        ang = (SPFLOAT)p->tpidsr*frq;
        fsc = sin(ang) - 3.0;

        rrad1 =  pow(10.0, fsc/(dc*sp->sr));
        rrad2 =  pow(10.0, fsc/(rs*sp->sr));
    }

    w1  = *in + 2.0*rrad1*cos(ang)*delay[0] - rrad1*rrad1*delay[1];
    y1 =  w1 - delay[1];
    delay[1] = delay[0];
    delay[0] = w1;

    w2  = *in + 2.0*rrad2*cos(ang)*delay[2] - rrad2*rrad2*delay[3];
    y2 =  w2 - delay[3];
    delay[3] = delay[2];
    delay[2] = w2;

    *out = (SPFLOAT) (y1 - y2);

    return SP_OK;
}
