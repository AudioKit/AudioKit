#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_delay_create(sp_delay **p)
{
    *p = malloc(sizeof(sp_delay));
    return SP_OK;
}

int sp_delay_destroy(sp_delay **p)
{
    sp_delay *pp = *p;
    sp_auxdata_free(&pp->buf);
    free(*p);
    return SP_OK;
}

int sp_delay_init(sp_data *sp, sp_delay *p, SPFLOAT time)
{
    p->time = time;
    p->bufsize = round(time * sp->sr);
    sp_auxdata_alloc(&p->buf, p->bufsize * sizeof(SPFLOAT));
    p->bufpos = 0;
    p->feedback = 0;
    p->last = 0;
    return SP_OK;
}

int sp_delay_compute(sp_data *sp, sp_delay *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT delay = 0, sig = 0;
    SPFLOAT *buf = (SPFLOAT *)p->buf.ptr; 
    delay = buf[p->bufpos];
    sig = (delay * p->feedback) + *in;
    buf[p->bufpos] = sig;
    p->bufpos = (p->bufpos + 1) % p->bufsize;
    *out = delay;
    return SP_OK;
}
