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

static void line_reinit(sp_data *sp, sp_line *p)
{
    SPFLOAT onedsr = 1.0 / sp->sr;
    p->incr = (SPFLOAT)((p->b - p->a) / (p->dur)) * onedsr;
    p->val = p->a;
    p->stime = 0;
    p->sdur = sp->sr * p->dur;
}

int sp_line_init(sp_data *sp, sp_line *p)
{
    p->a = 0;
    p->dur = 0.5;
    p->b = 1;
    line_reinit(sp, p);
    p->init = 1;
    return SP_OK;
}

int sp_line_compute(sp_data *sp, sp_line *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in != 0 ) {
        line_reinit(sp, p);
        p->init = 0;
    }

    if(p->init) {
        *out = 0;
        return SP_OK;
    }

    if(p->stime < p->sdur) {
        SPFLOAT val = p->val;
        p->val += p->incr;
        p->stime++;
        *out = val;
    } else {
        *out = p->b;
    }

    return SP_OK;
}
