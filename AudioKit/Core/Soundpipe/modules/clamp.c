#include <stdlib.h>
#include "soundpipe.h"

int sp_clamp_create(sp_clamp **p)
{
    *p = malloc(sizeof(sp_clamp));
    return SP_OK;
}

int sp_clamp_destroy(sp_clamp **p)
{
    free(*p);
    return SP_OK;
}

int sp_clamp_init(sp_data *sp, sp_clamp *p)
{
    p->min = 0;
    p->max = 1;
    return SP_OK;
}

int sp_clamp_compute(sp_data *sp, sp_clamp *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in < p->min) *out = p->min;
    else if(*in > p->max) *out = p->max;
    else *out = *in;
    return SP_OK;
}
