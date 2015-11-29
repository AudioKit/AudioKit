#include <stdlib.h>
#include "soundpipe.h"

int sp_samphold_create(sp_samphold **p)
{
    *p = malloc(sizeof(sp_samphold));
    return SP_OK;
}

int sp_samphold_destroy(sp_samphold **p)
{
    free(*p);
    return SP_OK;
}

int sp_samphold_init(sp_data *sp, sp_samphold *p)
{
    p->val = 0;
    return SP_OK;
}

int sp_samphold_compute(sp_data *sp, sp_samphold *p, SPFLOAT *trig, SPFLOAT *in, SPFLOAT *out)
{
    if(*trig != 0) {
        p->val = *in;
    }
    *out = p->val;
    return SP_OK;
}
