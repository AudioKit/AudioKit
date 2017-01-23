#include <stdlib.h>
#include "soundpipe.h"

int sp_timer_create(sp_timer **p)
{
    *p = malloc(sizeof(sp_timer));
    return SP_OK;
}

int sp_timer_destroy(sp_timer **p)
{
    free(*p);
    return SP_OK;
}

int sp_timer_init(sp_data *sp, sp_timer *p)
{
    p->mode = 0;
    p->pos = 0;
    p->time = 0;
    return SP_OK;
}

int sp_timer_compute(sp_data *sp, sp_timer *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in != 0) {
        if(p->mode == 0) {
            p->pos = 0;
            p->mode = 1;
        } else if(p->mode == 1) {
            p->time = (SPFLOAT) p->pos / sp->sr;
            p->mode = 0;
        }
    }

    if(p->mode == 1) {
        p->pos++;
    }

    *out = p->time;
    return SP_OK;
}
