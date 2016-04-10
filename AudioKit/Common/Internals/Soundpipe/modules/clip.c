/*
 * Clip
 * 
 * This code has been extracted from the Csound opcode "clip".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): John ffitch, Istvan Varga, Peter Neubäcker,
                       rasmus ekman, Phil Burk
 * Year: 1999
 * Location: Opcodes/pitch.c
 *
 */

#include <math.h>
#include <stdint.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif 

#include "soundpipe.h"

int sp_clip_create(sp_clip **p)
{
    *p = malloc(sizeof(sp_clip));
    return SP_OK;
}

int sp_clip_destroy(sp_clip **p)
{
    free(*p);
    return SP_OK;
}

int sp_clip_init(sp_data *sp, sp_clip *p)
{
    p->lim = 1;
    p->k1 = M_PI / (2.0 * p->lim);
    return SP_OK;
}

int sp_clip_compute(sp_data *sp, sp_clip *p, SPFLOAT *in, SPFLOAT *out)
{
    p->k1 = M_PI / (2.0 * p->lim);
    SPFLOAT k1 = p->k1;
    SPFLOAT limit = p->lim;
    SPFLOAT x;

    x = *in;
    if (x >= limit) {
        x = limit;
    } else if (x <= -limit) {
        x = -limit;
    } else {
        x = limit * sin(k1 * x);
    }
    *out = x;

    return SP_OK;
}
