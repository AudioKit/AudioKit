#include <stdlib.h>
#include "soundpipe.h"

int sp_tin_create(sp_tin **p)
{
    *p = malloc(sizeof(sp_tin));
    return SP_OK;
}

int sp_tin_destroy(sp_tin **p)
{
    free(*p);
    return SP_OK;
}

int sp_tin_init(sp_data *sp, sp_tin *p)
{
    p->fp = stdin; 
    p->val = 0;
    return SP_OK;
}

int sp_tin_compute(sp_data *sp, sp_tin *p, SPFLOAT *in, SPFLOAT *out)
{
    if(*in) {
        fread(&p->val, sizeof(SPFLOAT), 1, p->fp);
    }

    *out = p->val;
    return SP_OK;
}
