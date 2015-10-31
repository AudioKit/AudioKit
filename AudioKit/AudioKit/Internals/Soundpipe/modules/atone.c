/*
 * ATone
 * 
 * This code has been extracted from the Csound opcode "atone".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Barry Vercoe, John FFitch, Gabriel Maldonado
 * Year: 1991
 * Location: OOps/ugens5.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif 

int sp_atone_create(sp_atone **p)
{
    *p = malloc(sizeof(sp_atone));
    return SP_OK;
}

int sp_atone_destroy(sp_atone **p)
{
    free(*p);
    return SP_OK;
}

int sp_atone_init(sp_data *sp, sp_atone *p)
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

int sp_atone_compute(sp_data *sp, sp_atone *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT c2 = p->c2, yt1 = p->yt1;
    SPFLOAT x;

    if (p->hp != p->prvhp) {
      SPFLOAT b;
      p->prvhp = p->hp;
      b = 2.0 - cos((SPFLOAT)(p->hp * p->tpidsr));
      p->c2 = c2 = b - sqrt(b * b - 1.0);
    }

    x = yt1 = c2 * (yt1 + *in);
    *out = x;
    yt1 -= *in;
    p->yt1 = yt1;
    return SP_OK;
}
