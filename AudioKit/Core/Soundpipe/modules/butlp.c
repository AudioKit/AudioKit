/*
 * Butterworth Filters
 *
 * This code has been extracted from the Csound butterworth filter opcodes
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Paris Smaragdis, John ffitch
 * Year: 1994
 * Location: Opcodes/butter.c
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

static int sp_butter_filter(SPFLOAT *in, SPFLOAT *out, SPFLOAT *a)
{
    SPFLOAT t, y;
    t = *in - a[4] * a[6] - a[5] * a[7];
    y = t * a[1] + a[2] * a[6] + a[3] * a[7];
    a[7] = a[6];
    a[6] = t;
    *out = y;
    return SP_OK;
}

int sp_butlp_create(sp_butlp **p)
{
    *p = malloc(sizeof(sp_butlp));
    return SP_OK;
}

int sp_butlp_destroy(sp_butlp **p)
{
    free(*p);
    return SP_OK;
}

int sp_butlp_init(sp_data *sp, sp_butlp *p)
{
    p->istor = 0.0;
    p->sr = sp->sr;
    p->freq = 1000;
    p->pidsr = M_PI / sp->sr * 1.0;
    if (p->istor==0.0) {
        p->a[6] = p->a[7] = 0.0;
        p->lkf = 0.0;
    }
    return SP_OK;
}

int sp_butlp_compute(sp_data *sp, sp_butlp *p, SPFLOAT *in, SPFLOAT *out)
{
    if (p->freq <= 0.0){
      *out = 0;
      return SP_OK;
    }

    if (p->freq != p->lkf){
        SPFLOAT *a, c;
        a = p->a;
        p->lkf = p->freq;
        c = 1.0 / tan((SPFLOAT)(p->pidsr * p->lkf));
        a[1] = 1.0 / ( 1.0 + ROOT2 * c + c * c);
        a[2] = a[1] + a[1];
        a[3] = a[1];
        a[4] = 2.0 * ( 1.0 - c*c) * a[1];
        a[5] = ( 1.0 - ROOT2 * c + c * c) * a[1];
    }

    sp_butter_filter(in, out, p->a);
    return SP_OK;
}

