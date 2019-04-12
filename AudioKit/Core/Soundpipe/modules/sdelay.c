#include <stdlib.h>
#include "soundpipe.h"

int sp_sdelay_create(sp_sdelay **p)
{
    *p = malloc(sizeof(sp_sdelay));
    sp_sdelay *pp = *p;
    pp->size = 0;
    return SP_OK;
}

int sp_sdelay_destroy(sp_sdelay **p)
{
    sp_sdelay *pp = *p;

    if(pp->size > 0) {
        free(pp->buf);
    }

    free(*p);
    return SP_OK;
}

int sp_sdelay_init(sp_data *sp, sp_sdelay *p, int size)
{
    int n;
    p->size = size;
    p->buf = malloc(size * sizeof(SPFLOAT));
    for(n = 0; n < p->size; n++) p->buf[n] = 0;
    p->pos = 0;
    return SP_OK;
}

int sp_sdelay_compute(sp_data *sp, sp_sdelay *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = p->buf[p->pos];
    p->buf[p->pos] = *in;
    p->pos = (p->pos + 1) % p->size;
    return SP_OK;
}
