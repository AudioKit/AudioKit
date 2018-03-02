/*
 * Tone
 *
 * This code has been extracted from the Csound opcode "tone".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Barry Vercoe, John FFitch, Gabriel Maldonado
 * Year: 1991
 * Location: OOps/ugens5.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif

#include "soundpipe.h"


int sp_tone_create(sp_tone **t)
{
    *t = malloc(sizeof(sp_tone));
    return SP_OK;
}

int sp_tone_destroy(sp_tone **t)
{
    free(*t);
    return SP_OK;
}

int sp_tone_init(sp_data *sp, sp_tone *p)
{
    p->hp = 1000;
    SPFLOAT b;
    p->tpidsr = (2.0 * M_PI) / sp->sr * 1.0;
    p->prvhp = (SPFLOAT)p->hp;
    b = 2.0 - cos((SPFLOAT)(p->prvhp * p->tpidsr));
    p->c2 = b - sqrt(b * b - 1.0);
    p->c1 = 1.0 - p->c2;
    p->yt1 = 0.0;

    return SP_OK;
}

int sp_tone_compute(sp_data *sp, sp_tone *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT c1 = p->c1, c2 = p->c2;
    SPFLOAT yt1 = p->yt1;

    if (p->hp != p->prvhp) {
      SPFLOAT b;
      p->prvhp = p->hp;
      b = 2.0 - cos((p->prvhp * p->tpidsr));
      p->c2 = c2 = b - sqrt(b * b - 1.0);
      p->c1 = c1 = 1.0 - c2;
    }

    yt1 = c1 * (*in) + c2 * yt1;
    *out = yt1;

    p->yt1 = yt1;
    return SP_OK;
}
