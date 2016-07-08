/*
 * Allpass
 * 
 * This code has been extracted from the Csound opcode "allpass".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Barry Vercoe, John ffitch
 * Year: 1991
 * Location: Opcodes/ugens6.c
 *
 */

#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"

int sp_allpass_create(sp_allpass **p)
{
    *p = malloc(sizeof(sp_allpass));
    return SP_OK;
}

int sp_allpass_destroy(sp_allpass **p)
{
    sp_allpass *pp = *p;
    sp_auxdata_free(&pp->aux);
    free(*p);
    return SP_OK;
}

int sp_allpass_init(sp_data *sp, sp_allpass *p, SPFLOAT looptime)
{
    p->revtime = 3.5;
    p->looptime = looptime;
    p->bufsize = 0.5 + looptime * sp->sr;
    sp_auxdata_alloc(&p->aux, p->bufsize * sizeof(SPFLOAT));
    p->prvt = 0.0;
    p->coef = 0.0;
    p->bufpos = 0;
    return SP_OK;
}

int sp_allpass_compute(sp_data *sp, sp_allpass *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT y, z;
    SPFLOAT coef = p->coef;
    SPFLOAT *buf = (SPFLOAT *)p->aux.ptr;
    if(p->prvt != p->revtime) {
        p->prvt = p->revtime;
        coef = p->coef = exp(-6.9078 * p->looptime / p->prvt);
    }
    y = buf[p->bufpos];
    z = coef * y + *in; 
    buf[p->bufpos] = z;
    *out = y - coef * z;

    p->bufpos++;
    p->bufpos %= p->bufsize; 
    return SP_OK;
}
