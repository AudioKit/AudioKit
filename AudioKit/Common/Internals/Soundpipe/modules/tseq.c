#include <stdlib.h>
#include "soundpipe.h"

int sp_tseq_create(sp_tseq **p)
{
    *p = malloc(sizeof(sp_tseq));
    return SP_OK;
}

int sp_tseq_destroy(sp_tseq **p)
{
    free(*p);
    return SP_OK;
}

int sp_tseq_init(sp_data *sp, sp_tseq *p, sp_ftbl *ft)
{
    p->ft = ft;
    p->pos = -1;
    p->val = 0;
    p->shuf = 0;
    return SP_OK;
}

int sp_tseq_compute(sp_data *sp, sp_tseq *p, SPFLOAT *trig, SPFLOAT *val)
{    
    if(*trig != 0){
        if(p->shuf) {
            p->pos = sp_rand(sp) % p->ft->size;
        } else {
            p->pos = (p->pos + 1) % p->ft->size;
        }
        p->val = p->ft->tbl[p->pos];
    }
    *val = p->val;
    return SP_OK;
}
