#include <stdlib.h>
#include "soundpipe.h"

int sp_random_create(sp_random **p)
{
    *p = malloc(sizeof(sp_random));
    return SP_OK;
}

int sp_random_destroy(sp_random **p)
{
    free(*p);
    return SP_OK;
}

int sp_random_init(sp_data *sp, sp_random *p)
{
    p->min = -1;
    p->max = 1;
    return SP_OK;
}

int sp_random_compute(sp_data *sp, sp_random *p, SPFLOAT *in, SPFLOAT *out)
{
    /* Send the signal's input to the output */
    SPFLOAT rnd = ((sp_rand(sp) % RAND_MAX) / (RAND_MAX * 1.0));
    rnd *= (p->max - p->min);
    rnd += p->min;
    *out = rnd;
    return SP_OK;
}
