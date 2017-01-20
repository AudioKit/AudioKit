#include <stdlib.h>
#include "soundpipe.h"

int sp_dmetro_create(sp_dmetro **p)
{
    *p = malloc(sizeof(sp_dmetro));
    return SP_OK;
}

int sp_dmetro_destroy(sp_dmetro **p)
{
    free(*p);
    return SP_OK;
}

int sp_dmetro_init(sp_data *sp, sp_dmetro *p)
{
    p->counter = 0;
    p->time = 1.0;
    return SP_OK;
}

int sp_dmetro_compute(sp_data *sp, sp_dmetro *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 0; 

    if(p->counter == 0) {
        *out = 1.0;
        p->counter = (int)(sp->sr * p->time) + 1;
    }

    p->counter--; 

    return SP_OK;
}
