/*
 * Expon
 *
 * This code has been extracted from the Csound opcode "expon".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Barry Vercoe
 * Year: 1991
 * Location: OOps/ugens1.c
 *
 */

#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"

int sp_expon_create(sp_expon **p)
{
    *p = malloc(sizeof(sp_expon));
    return SP_OK;
}

int sp_expon_destroy(sp_expon **p)
{
    free(*p);
    return SP_OK;
}

int sp_expon_init(sp_data *sp, sp_expon *p, SPFLOAT ia, SPFLOAT idur, SPFLOAT ib)
{
    SPFLOAT onedsr = 1.0 / sp->sr;
    p->ia = ia;
    p->ib = ib;
    p->idur = idur;
    p->stime = 0;
    p->sdur = idur * sp->sr;
    if((p->ia * p->ib) > 0.0) {
        p->incr = pow((SPFLOAT)(p->ib / p->ia), onedsr / p->idur);
    } else {
        fprintf(stderr, "Warning: p values must be non-zero\n");
        p->incr = 1;
        p->val = p->ia;
        return SP_NOT_OK;
    }
    p->val = p->ia;
    return SP_OK;
}

int sp_expon_compute(sp_data *sp, sp_expon *p, SPFLOAT *in, SPFLOAT *out)
{
    /* Send the signal's input to the output */
    if(p->stime < p->sdur) {
        SPFLOAT val = p->val;
        p->val *= p->incr;
        p->stime++;
        *out = val;
    } else {
        *out = p->ib;
    }
    return SP_OK;
}
