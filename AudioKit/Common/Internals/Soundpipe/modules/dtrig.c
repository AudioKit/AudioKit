#include <stdlib.h>
#include "soundpipe.h"

int sp_dtrig_create(sp_dtrig **p)
{
    *p = malloc(sizeof(sp_dtrig));
    return SP_OK;
}

int sp_dtrig_destroy(sp_dtrig **p)
{
    free(*p);
    return SP_OK;
}

int sp_dtrig_init(sp_data *sp, sp_dtrig *p, sp_ftbl *ft)
{
    p->ft = ft;
    p->counter = 0;
    p->pos = 0; 
    p->running = 0;
    p->loop = 0;
    p->delay = 0;
    p->scale = 1;
    return SP_OK;
}

int sp_dtrig_compute(sp_data *sp, sp_dtrig *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in == 1.0){
        p->running = 1.0;
        p->pos = 0;
        p->counter = p->delay * sp->sr;
    } 
    if((p->pos < p->ft->size) && p->running){
        if(p->counter == 0){
            p->counter = (uint32_t)(p->scale * p->ft->tbl[p->pos] * sp->sr - 1);
            *out = 1.0;
            p->pos++; 
            if(p->loop){
                p->pos %= p->ft->size;
            }
            return SP_OK;
        }else{
            *out = 0;
            p->counter--;
            return SP_OK;
        }
    }    
    *out = 0;
    return SP_NOT_OK;
}
