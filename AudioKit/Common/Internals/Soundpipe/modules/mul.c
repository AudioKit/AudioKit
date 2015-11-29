#include <stdlib.h>
#include "soundpipe.h"

int sp_mul_create(sp_mul **p)
{
    *p = malloc(sizeof(sp_mul));
    return SP_OK;
}

int sp_mul_destroy(sp_mul **p)
{
    free(*p);
    return SP_OK;
}

int sp_mul_init(sp_data *sp, sp_mul *p)
{
    return SP_OK;
}

int sp_mul_compute(sp_data *sp, sp_mul *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out)
{
    /* Send the signal's input to the output */
    *out = *in1 * *in2;
    return SP_OK;
}
