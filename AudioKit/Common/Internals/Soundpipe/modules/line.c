#include <stdlib.h>
#include "soundpipe.h"

int sp_line_create(sp_line **p)
{
    *p = malloc(sizeof(sp_line));
    return SP_OK;
}

int sp_line_destroy(sp_line **p)
{
    free(*p);
    return SP_OK;
}

int sp_line_init(sp_data *sp, sp_line *p, SPFLOAT ia, SPFLOAT idur, SPFLOAT ib)
{
    SPFLOAT onedsr = 1.0 / sp->sr;
    p->ia = ia;
    p->idur = idur;
    p->ib = ib;
    p->incr = (SPFLOAT)((p->ib - p->ia) / (p->idur)) * onedsr;
    p->val = p->ia;
    p->stime = 0;
    p->sdur = sp->sr * idur;
    return SP_OK;
}

int sp_line_compute(sp_data *sp, sp_line *p, SPFLOAT *in, SPFLOAT *out)
{
    if(p->stime < p->sdur) {
        SPFLOAT val = p->val;
        p->val += p->incr;
        p->stime++;
        *out = val;
    } else {
        *out = p->ib;
    }
    return SP_OK;
}
