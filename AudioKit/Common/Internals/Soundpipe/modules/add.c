#include <stdlib.h>
#include "soundpipe.h"

int sp_add_create(sp_add **p)
{
    *p = malloc(sizeof(sp_add));
    return SP_OK;
}

int sp_add_destroy(sp_add **p)
{
    free(*p);
    return SP_OK;
}

int sp_add_init(sp_data *sp, sp_add *p)
{
    return SP_OK;
}

int sp_add_compute(sp_data *sp, sp_add *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out)
{
    /* Send the signal's input to the output */
    *out = *in1 + *in2;
    return SP_OK;
}
