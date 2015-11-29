#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_abs_create(sp_abs **p)
{
    *p = malloc(sizeof(sp_abs));
    return SP_OK;
}

int sp_abs_destroy(sp_abs **p)
{
    free(*p);
    return SP_OK;
}

int sp_abs_init(sp_data *sp, sp_abs *p)
{
    return SP_OK;
}

int sp_abs_compute(sp_data *sp, sp_abs *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = fabsf(*in);
    return SP_OK;
}
