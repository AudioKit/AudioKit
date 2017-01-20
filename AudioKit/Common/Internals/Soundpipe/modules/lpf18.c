/*
 * LPF18 
 * 
 * This code has been extracted from the Csound opcode "lpf18".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): John ffitch, Josep Comajuncosas 
 * Year: 2000
 * Location: Opcodes/pitch.c
 *
 */

#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"

int sp_lpf18_create(sp_lpf18 **p)
{
    *p = malloc(sizeof(sp_lpf18));
    return SP_OK;
}

int sp_lpf18_destroy(sp_lpf18 **p)
{
    free(*p);
    return SP_OK;
}

int sp_lpf18_init(sp_data *sp, sp_lpf18 *p)
{
    p->cutoff = 1000;
    p->res = 0.8;
    p->dist = 2;

    p->ay1 = 0.0;
    p->ay2 = 0.0;
    p->aout = 0.0;
    p->lastin = 0.0;
    p->onedsr = 1.0 / sp->sr;
    return SP_OK;
}

int sp_lpf18_compute(sp_data *sp, sp_lpf18 *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT ay1 = p->ay1;
    SPFLOAT ay2 = p->ay2;
    SPFLOAT aout = p->aout;
    SPFLOAT lastin = p->lastin;
    double value = 0.0;
    int   flag = 1;
    SPFLOAT lfc=0, lrs=0, kres=0, kfcn=0, kp=0, kp1=0,  kp1h=0;
    double lds = 0.0;

    SPFLOAT fco, res, dist;
    SPFLOAT ax1  = lastin;
    SPFLOAT ay11 = ay1;
    SPFLOAT ay31 = ay2;
    fco = p->cutoff;
    res = p->res;
    dist = p->dist;

    if (fco != lfc || flag) {
        lfc = fco;
        kfcn = 2.0 * fco * p->onedsr;
        kp = ((-2.7528 * kfcn + 3.0429) * kfcn +
                1.718) * kfcn - 0.9984;
        kp1 = kp + 1.0;
        kp1h = 0.5 * kp1;
        flag = 1;
    }

    if (res != lrs || flag) {
        lrs = res;
        kres = res * (((-2.7079 * kp1 + 10.963) * kp1
                           - 14.934) * kp1 + 8.4974);
        flag = 1;
    }

    if (dist != lds || flag) {
        lds = dist;
        value = 1.0 + (dist * (1.5 + 2.0 * res * (1.0 - kfcn)));
    }

    flag = 0;
    lastin = *in - tanh(kres*aout);
    ay1 = kp1h * (lastin + ax1) - kp * ay1;
    ay2 = kp1h * (ay1 + ay11) - kp * ay2;
    aout = kp1h * (ay2 + ay31) - kp * aout;

    *out = tanh(aout * value);

    p->ay1 = ay1;
    p->ay2 = ay2;
    p->aout = aout;
    p->lastin = lastin;
    return SP_OK;
}
