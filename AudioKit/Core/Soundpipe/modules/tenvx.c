#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_tenvx_create(sp_tenvx **p)
{
    *p = malloc(sizeof(sp_tenvx));
    return SP_OK;
}

int sp_tenvx_destroy(sp_tenvx **p)
{
    free(*p);
    return SP_OK;
}


int sp_tenvx_init(sp_data *sp, sp_tenvx *p)
{
    p->hold = 0.5;
    p->atk = 0.5;
    p->rel = 0.5;
    p->a_a = p->b_a = 0;
    p->a_r = p->b_r = 0;
    p->y = 0;
    p->count = (uint32_t) (p->hold * sp->sr);
    return SP_OK;
}


int sp_tenvx_compute(sp_data *sp, sp_tenvx *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 0;

    if(*in != 0) {
        p->a_a = exp(-1.0/(p->atk * sp->sr));
        p->b_a = 1.0 - p->a_a;
        p->a_r = exp(-1.0/(p->rel * sp->sr));
        p->b_r = 1.0 - p->a_r;
        p->count = (uint32_t) (p->hold * sp->sr);
    }

    if(p->count > 0) {
        *out = p->b_a + p->a_a * p->y;
        p->y = *out;
        p->count--;
    } else {
        *out = p->a_r * p->y;
        p->y = *out;
    }

    return SP_OK;
}
