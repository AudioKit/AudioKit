#include <stdlib.h>
#include "soundpipe.h"

int sp_trand_create(sp_trand **p)
{
    *p = malloc(sizeof(sp_trand));
    return SP_OK;
}

int sp_trand_destroy(sp_trand **p)
{
    free(*p);
    return SP_OK;
}

int sp_trand_init(sp_data *sp, sp_trand *p)
{
    p->min = 0;
    p->max = 1;
    p->val = 0;
    return SP_OK;
}

int sp_trand_compute(sp_data *sp, sp_trand *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in != 0) {
        p->val = p->min + ((SPFLOAT) sp_rand(sp) / SP_RANDMAX) * (p->max - p->min);
        *out = p->val;
    } else {
        *out = p->val;
    }
    return SP_OK;
}
