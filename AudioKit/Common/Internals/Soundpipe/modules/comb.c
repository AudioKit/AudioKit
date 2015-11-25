/*
 * Allpass 
 * 
 * This code has been extracted from the Csound opcode "comb".
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

int sp_comb_create(sp_comb **p)
{
    *p = malloc(sizeof(sp_comb));
    return SP_OK;
}

int sp_comb_destroy(sp_comb **p)
{
    sp_comb *pp = *p;
    sp_auxdata_free(&pp->aux);
    free(*p);
    return SP_OK;
}

int sp_comb_init(sp_data *sp, sp_comb *p, SPFLOAT looptime)
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

int sp_comb_compute(sp_data *sp, sp_comb *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT samp = 0;
    SPFLOAT coef = p->coef;

    if(p->prvt != p->revtime) {
        p->prvt = p->revtime;
        coef = p->coef = exp(-6.9078 * p->looptime / p->prvt);
    }
    sp_auxdata_getbuf(&p->aux, p->bufpos, &samp);
    *out = samp;
    samp *= coef;
    samp += *in;
    sp_auxdata_setbuf(&p->aux, p->bufpos, &samp);

    p->bufpos++;
    p->bufpos %= p->bufsize; 
    return SP_OK;
}
