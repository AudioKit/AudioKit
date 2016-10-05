#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_tseg_create(sp_tseg **p)
{
    *p = malloc(sizeof(sp_tseg));
    return SP_OK;
}

int sp_tseg_destroy(sp_tseg **p)
{
    free(*p);
    return SP_OK;
}

int sp_tseg_init(sp_data *sp, sp_tseg *p, SPFLOAT ibeg)
{
    p->beg = ibeg;
    p->end = 1.0;
    p->val = ibeg;
    p->type = -3;
    p->slope = 1.0;
    p->dur = 1.0;
    p->tdivnsteps = 0.0;
    p->count = 0;
    p->steps = p->dur * sp->sr;
    return SP_OK;
}

int sp_tseg_compute(sp_data *sp, sp_tseg *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = p->val;
    if(*in != 0) {
        p->slope = 1.0 / (1.0 - exp(p->type));
        p->beg = p->val;
        p->count = 0;
        p->steps = p->dur * sp->sr;
        p->tdivnsteps = (SPFLOAT)p->type / (p->steps - 1);
    }
    if(p->count < p->steps) {
        *out = p->beg + (p->end - p->beg) * 
            ((1 - exp(p->count * p->tdivnsteps)) * p->slope);
        p->val = *out;
        p->count++;
    }
    return SP_OK;
}
