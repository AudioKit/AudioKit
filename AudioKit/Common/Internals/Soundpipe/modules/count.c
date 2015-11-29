#include <stdlib.h>
#include "soundpipe.h"

int sp_count_create(sp_count **p)
{
    *p = malloc(sizeof(sp_count));
    return SP_OK;
}

int sp_count_destroy(sp_count **p)
{
    free(*p);
    return SP_OK;
}

int sp_count_init(sp_data *sp, sp_count *p)
{
    p->count = 4;
    p->curcount = -1;
    p->mode = 0;
    return SP_OK;
}

int sp_count_compute(sp_data *sp, sp_count *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in){
        if(p->mode == 0) {
            p->curcount = (p->curcount + 1) % p->count;
        } else {
            if(p->curcount == -2) {
                *out = -2;
                return SP_OK;
            }
            if(p->curcount >= p->count - 1) {
                p->curcount = -2;
            } else {
                if(p->curcount == -1) p->curcount = 0;
                else p->curcount++;
            }
        }
    }
    *out = p->curcount;
    return SP_OK;
}
