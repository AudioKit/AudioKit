#include <stdlib.h>
#include "soundpipe.h"

#ifndef max
#define max(a, b) ((a > b) ? a : b)
#endif

#ifndef min
#define min(a, b) ((a < b) ? a : b)
#endif


int sp_incr_create(sp_incr **p)
{
    *p = malloc(sizeof(sp_incr));
    return SP_OK;
}

int sp_incr_destroy(sp_incr **p)
{
    free(*p);
    return SP_OK;
}

int sp_incr_init(sp_data *sp, sp_incr *p, SPFLOAT val)
{
    p->min = 0;
    p->max = 1;
    p->step = 0.1;
    p->val = val;
    return SP_OK;
}

int sp_incr_compute(sp_data *sp, sp_incr *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in > 0 ) {
        p->val += p->step;
        p->val = max(min(p->val, p->max), p->min);
    } else if (*in < 0) {
        p->val -= p->step;
        p->val = max(min(p->val, p->max), p->min);
    }
    *out = p->val;
    return SP_OK;
}
