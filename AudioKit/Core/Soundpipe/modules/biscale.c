#include <stdlib.h>
#include "soundpipe.h"

int sp_biscale_create(sp_biscale **p)
{
    *p = malloc(sizeof(sp_biscale));
    return SP_OK;
}

int sp_biscale_destroy(sp_biscale **p)
{
    free(*p);
    return SP_OK;
}

int sp_biscale_init(sp_data *sp, sp_biscale *p)
{
    p->min = 0;
    p->max = 1;
    return SP_OK;
}

int sp_biscale_compute(sp_data *sp, sp_biscale *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = p->min + (*in + 1.0) / 2.0 * (p->max - p->min);
    return SP_OK;
}
