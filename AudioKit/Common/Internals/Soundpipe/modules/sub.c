#include <stdlib.h>
#include "soundpipe.h"

int sp_sub_create(sp_sub **p)
{
    *p = malloc(sizeof(sp_sub));
    return SP_OK;
}

int sp_sub_destroy(sp_sub **p)
{
    free(*p);
    return SP_OK;
}

int sp_sub_init(sp_data *sp, sp_sub *p)
{
    return SP_OK;
}

int sp_sub_compute(sp_data *sp, sp_sub *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out)
{
    /* Send the signal's input to the output */
    *out = *in1 - *in2;
    return SP_OK;
}
