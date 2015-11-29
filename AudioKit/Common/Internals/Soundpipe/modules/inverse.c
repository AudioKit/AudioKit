#include <stdlib.h>
#include "soundpipe.h"

int sp_inverse_create(sp_inverse **p)
{
    *p = malloc(sizeof(sp_inverse));
    return SP_OK;
}

int sp_inverse_destroy(sp_inverse **p)
{
    free(*p);
    return SP_OK;
}

int sp_inverse_init(sp_data *sp, sp_inverse *p)
{
    return SP_OK;
}

int sp_inverse_compute(sp_data *sp, sp_inverse *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 1.0 / *in;
    return SP_OK;
}
