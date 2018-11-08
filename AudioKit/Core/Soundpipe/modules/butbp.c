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

int sp_butbp_create(sp_butbp **p)
{
    *p = malloc(sizeof(sp_butbp));
    return SP_OK;
}

int sp_butbp_destroy(sp_butbp **p)
{
    free(*p);
    return SP_OK;
}

int sp_butbp_init(sp_data *sp, sp_butbp *p)
{
    p->istor = 0.0;
    p->sr = sp->sr;
    p->freq = 1000;
    p->bw = 10;
    p->pidsr = M_PI / sp->sr * 1.0;
    p->tpidsr = 2 * M_PI / sp->sr * 1.0;
    p->a[6] = p->a[7] = 0.0;
    p->lkf = 0.0;
    p->lkb = 0.0;
    return SP_OK;
}

int sp_butbp_compute(sp_data *sp, sp_butbp *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT *a = p->a;
    SPFLOAT t, y;

    if (p->bw <= 0.0) {
       *out = 0;
       return SP_OK;
    }

    SPFLOAT bw, fr;
    bw = p->bw;
    fr = p->freq;

    if (bw != p->lkb || fr != p->lkf) {
        SPFLOAT c, d;
        p->lkf = fr;
        p->lkb = bw;
        c = 1.0 / tan((SPFLOAT)(p->pidsr * bw));
        d = 2.0 * cos((SPFLOAT)(p->tpidsr * fr));
        a[1] = 1.0 / (1.0 + c);
        a[2] = 0.0;
        a[3] = -a[1];
        a[4] = - c * d * a[1];
        a[5] = (c - 1.0) * a[1];
    }
    t = *in - a[4] * a[6] - a[5] * a[7];
    y = t * a[1] + a[2] * a[6] + a[3] * a[7];
    a[7] = a[6];
    a[6] = t;
    *out = y;
    return SP_OK;
}
