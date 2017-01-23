#include <stdlib.h>
#include "soundpipe.h"

enum {
    T_ON,
    T_OFF,
    T_INIT
};

int sp_tenv2_create(sp_tenv2 **p)
{
    *p = malloc(sizeof(sp_tenv2));
    return SP_OK;
}

int sp_tenv2_destroy(sp_tenv2 **p)
{
    free(*p);
    return SP_OK;
}

int sp_tenv2_init(sp_data *sp, sp_tenv2 *p)
{
    p->state = T_INIT;
    p->atk = 0.1;
    p->rel = 0.1;
    p->slope = 0;
    p->last = 0;
    return SP_OK;
}

int sp_tenv2_compute(sp_data *sp, sp_tenv2 *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in != 0) {
        if(p->state == T_INIT || p->state == T_OFF) {
            p->state = T_ON;
            p->timer = (uint32_t)(sp->sr * p->atk);
            p->totaltime = p->timer;
            p->slope = 1.0 / p->totaltime;
        } else if (p->state == T_ON) { 
            p->state = T_OFF;
            p->timer = (uint32_t)(sp->sr * p->rel);
            p->totaltime = p->timer;
            p->slope = 1.0 / p->totaltime;
        }
    }
    if(p->timer == 0) {
        if(p->state == T_ON) *out = 1;
        else *out = 0;
        return SP_OK;
    } else {
        p->timer--;
        if(p->state == T_ON)  {
            *out = p->last + p->slope;
        } else if (p->state == T_OFF) {
            *out = p->last - p->slope;
        }

        if(*out > 1) *out = 1;
        if(*out < 0) *out = 0;

        p->last = *out;

        return SP_OK;
    }
    return SP_OK;
}
