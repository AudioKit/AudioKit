#include <stdlib.h>
#include <string.h>
#include "soundpipe.h"

int sp_tblrec_create(sp_tblrec **p)
{
    *p = malloc(sizeof(sp_tblrec));
    return SP_OK;
}

int sp_tblrec_destroy(sp_tblrec **p)
{
    free(*p);
    return SP_OK;
}

int sp_tblrec_init(sp_data *sp, sp_tblrec *p, sp_ftbl *ft)
{
    p->index = 0;
    p->record = 0;
    p->ft = ft;
    return SP_OK;
}

int sp_tblrec_compute(sp_data *sp, sp_tblrec *p, SPFLOAT *in, SPFLOAT *trig, SPFLOAT *out)
{
    if(*trig != 0) {
        if(p->record == 1) {
            p->record = 0;
        } else {
            p->record = 1;
            p->index = 0;
            memset(p->ft->tbl, 0, sizeof(SPFLOAT) * p->ft->size);
        }
    }

    if(p->record) {
        p->ft->tbl[p->index] = *in;
        p->index = (p->index + 1) % p->ft->size;
    }
    return SP_OK;
}
