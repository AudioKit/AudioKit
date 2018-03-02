#include <stdlib.h>
#include "soundpipe.h"

int sp_crossfade_create(sp_crossfade **p)
{
    *p = malloc(sizeof(sp_crossfade));
    return SP_OK;
}

int sp_crossfade_destroy(sp_crossfade **p)
{
    free(*p);
    return SP_OK;
}

int sp_crossfade_init(sp_data *sp, sp_crossfade *p)
{
    p->pos = 0.5;
    return SP_OK;
}

int sp_crossfade_compute(sp_data *sp, sp_crossfade *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out)
{
    *out = *in2 * p->pos + *in1 * (1 - p->pos);
    return SP_OK;
}
