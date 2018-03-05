#include <stdlib.h>
#include "soundpipe.h"

int sp_slice_create(sp_slice **p)
{
    *p = malloc(sizeof(sp_slice));
    return SP_OK;
}

int sp_slice_destroy(sp_slice **p)
{
    free(*p);
    return SP_OK;
}

int sp_slice_init(sp_data *sp, sp_slice *p, sp_ftbl *vals, sp_ftbl *buf)
{
    p->vals = vals;
    p->buf = buf;
    p->pos = 0;
    p->nextpos = 0;
    p->id = 0;
    return SP_OK;
}

int sp_slice_compute(sp_data *sp, sp_slice *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 0;
    if(*in != 0) {
        if(p->id < p->vals->size) {
            p->pos = p->vals->tbl[p->id];
            if(p->id == p->vals->size - 1) {
                p->nextpos = (uint32_t)p->buf->size;
            } else {
                p->nextpos = p->vals->tbl[p->id + 1];
            }
        }
    }

    if(p->pos < p->nextpos) {
        *out = p->buf->tbl[p->pos];
        p->pos++;
    }

    return SP_OK;
}
