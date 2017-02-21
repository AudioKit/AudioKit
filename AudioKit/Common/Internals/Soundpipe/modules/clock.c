/*
 * Foo
 * 
 * This is a dummy module. It doesn't do much.
 * Feel free to use this as a boilerplate template.
 * 
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_clock_create(sp_clock **p)
{
    *p = malloc(sizeof(sp_clock));
    return SP_OK;
}

int sp_clock_destroy(sp_clock **p)
{
    free(*p);
    return SP_OK;
}

int sp_clock_init(sp_data *sp, sp_clock *p)
{
    p->subdiv = 1.0;
    p->bpm = 120;
    p->counter = 0;
    return SP_OK;
}

int sp_clock_compute(sp_data *sp, sp_clock *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 0.0;
    if(p->counter == 0 || *in != 0) {
        *out = 1.0;
        p->counter = (int)(sp->sr * (60.0 / (p->bpm * p->subdiv))) + 1;
    }
    p->counter--; 
    return SP_OK;
}
