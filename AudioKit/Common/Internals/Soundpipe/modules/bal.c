/*
 * Bal
 *
 * This code has been extracted from the Csound opcode "balance".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Barry Vercoe, john ffitch, Gabriel Maldonado
 * Year: 1991
 * Location: OOps/ugens5.c
 *
 */

#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif

int sp_bal_create(sp_bal **p)
{
    *p = malloc(sizeof(sp_bal));
    return SP_OK;
}

int sp_bal_destroy(sp_bal **p)
{
    free(*p);
    return SP_OK;
}

int sp_bal_init(sp_data *sp, sp_bal *p)
{

    SPFLOAT b;
    p->ihp = 10;
    b = 2.0 - cos((SPFLOAT)(p->ihp * (2.0 * M_PI / sp->sr)));
    p->c2 = b - sqrt(b*b - 1.0);
    p->c1 = 1.0 - p->c2;
    p->prvq = p->prvr = p->prva = 0.0;

    return SP_OK;
}

int sp_bal_compute(sp_data *sp, sp_bal *p, SPFLOAT *sig, SPFLOAT *comp, SPFLOAT *out)
{
    SPFLOAT q, r, a, diff;
    SPFLOAT c1 = p->c1, c2 = p->c2;

    q = p->prvq;
    r = p->prvr;
    SPFLOAT as = *sig;
    SPFLOAT cs = *comp;

    q = c1 * as * as + c2 * q;
    r = c1 * cs * cs + c2 * r;

    p->prvq = q;
    p->prvr = r;

    if (q != 0.0) {
        a = sqrt(r/q);
    } else {
        a = sqrt(r);
    }

    if((diff = a - p->prva) != 0.0) {
        *out = *sig * p->prva;
        p->prva = a;
    } else {
        *out = *sig * a;
    }

    return SP_OK;
}
