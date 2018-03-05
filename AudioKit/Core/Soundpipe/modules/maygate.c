#include <stdlib.h>
#include "soundpipe.h"

int sp_maygate_create(sp_maygate **p)
{
    *p = malloc(sizeof(sp_maygate));
    return SP_OK;
}

int sp_maygate_destroy(sp_maygate **p)
{
    free(*p);
    return SP_OK;
}

int sp_maygate_init(sp_data *sp, sp_maygate *p)
{
    p->prob = 0.0;
    p->gate = 0;
    p->mode = 0;
    return SP_OK;
}

int sp_maygate_compute(sp_data *sp, sp_maygate *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in == 0) {
        if(p->mode) {
            *out = 0;
        } else {
            *out = p->gate;
        }
        return SP_OK;
    }

    if((1.0 * sp_rand(sp) / SP_RANDMAX) <= p->prob) {
        *out = 1;
        p->gate = 1;
    } else {
        *out = 0;
        p->gate = 0;
    }
    return SP_OK;
}
