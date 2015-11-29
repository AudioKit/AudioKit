#include <stdlib.h>
#include "soundpipe.h"

int sp_tabread_create(sp_tabread **p)
{
    *p = malloc(sizeof(sp_tabread));
    return SP_OK;
}

int sp_tabread_destroy(sp_tabread **p)
{
    free(*p);
    return SP_OK;
}

int sp_tabread_init(sp_data *sp, sp_tabread *p, sp_ftbl *ft)
{
    p->pos = 0.0;
    p->speed = 1.0;
    p->ft = ft;
    return SP_OK;
}

int sp_tabread_compute(sp_data *sp, sp_tabread *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = p->ft->tbl[(uint32_t)p->pos];
    p->pos += p->speed;
    if(p->pos > p->ft->size) {
        p->pos = 0;
    } else if(p->pos < 0) {
        p->pos = p->ft->size;
    }
    return SP_OK;
}
