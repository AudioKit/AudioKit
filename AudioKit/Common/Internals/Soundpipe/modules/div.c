#include <stdlib.h>
#include "soundpipe.h"

int sp_div_create(sp_div **p)
{
    *p = malloc(sizeof(sp_div));
    return SP_OK;
}

int sp_div_destroy(sp_div **p)
{
    free(*p);
    return SP_OK;
}

int sp_div_init(sp_data *sp, sp_div *p)
{
    return SP_OK;
}

int sp_div_compute(sp_data *sp, sp_div *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out)
{
    /* Send the signal's input to the output */
    *out = *in1 / *in2;
    return SP_OK;
}
