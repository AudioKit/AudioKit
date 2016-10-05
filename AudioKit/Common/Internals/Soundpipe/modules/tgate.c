#include <stdlib.h>
#include "soundpipe.h"

int sp_tgate_create(sp_tgate **p)
{
    *p = malloc(sizeof(sp_tgate));
    return SP_OK;
}

int sp_tgate_destroy(sp_tgate **p)
{
    free(*p);
    return SP_OK;
}

int sp_tgate_init(sp_data *sp, sp_tgate *p)
{
    p->time = 0;
    p->timer = 0;
    return SP_OK;
}

int sp_tgate_compute(sp_data *sp, sp_tgate *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 0;
    if(*in != 0) {
        p->timer = p->time * sp->sr;
    }
    if(p->timer != 0) {
        *out = 1;
        p->timer--;
    }
    return SP_OK;
}
