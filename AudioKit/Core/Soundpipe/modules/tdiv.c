#include <stdlib.h>
#include "soundpipe.h"

int sp_tdiv_create(sp_tdiv **p)
{
    *p = malloc(sizeof(sp_tdiv));
    return SP_OK;
}

int sp_tdiv_destroy(sp_tdiv **p)
{
    free(*p);
    return SP_OK;
}

int sp_tdiv_init(sp_data *sp, sp_tdiv *p)
{
    p->num = 2;
    p->counter = 0;
    p->offset = 0;
    return SP_OK;
}

int sp_tdiv_compute(sp_data *sp, sp_tdiv *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 0.0;
    if(*in != 0) {
        if(p->counter == p->offset) *out = 1.0;
        else *out = 0.0;
        p->counter = (p->counter + 1) % p->num;
    }
    return SP_OK;
}
