/*
 * Phasor
 * 
 * This code has been extracted from the Csound opcode "phasor".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Barry Vercoe, John ffitch, Robin whittle
 * Year: 1991
 * Location: OOps/ugens2.c
 *
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_phasor_create(sp_phasor **p)
{
    *p = malloc(sizeof(sp_phasor));
    return SP_OK;
}

int sp_phasor_destroy(sp_phasor **p)
{
    free(*p);
    return SP_OK;
}

int sp_phasor_init(sp_data *sp, sp_phasor *p, SPFLOAT iphs)
{
    p->freq = 440;
    p->phs = iphs;
    p->curphs = iphs;
    p->onedsr = 1.0 / sp->sr;
    return SP_OK;
}

int sp_phasor_compute(sp_data *sp, sp_phasor *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT phase;
    SPFLOAT incr;

    phase = p->curphs;
    incr = p->freq * p->onedsr;
    *out = phase;
    phase += incr;
    if (phase >= 1.0) {
        phase -= 1.0;
    } else if (phase < 0.0) {
        phase += 1.0;
    }
    p->curphs = phase;
    return SP_OK;
}
