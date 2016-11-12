#include <stdlib.h>
#include "soundpipe.h"

int sp_randh_create(sp_randh **p)
{
    *p = malloc(sizeof(sp_randh));
    return SP_OK;
}

int sp_randh_destroy(sp_randh **p)
{
    free(*p);
    return SP_OK;
}

int sp_randh_init(sp_data *sp, sp_randh *p)
{
    p->counter = 0;
    p->freq = 10;
    p->dur = (sp->sr / p->freq);
    p->min = 0;
    p->max = 1;
    p->val = 0;
    return SP_OK;
}

int sp_randh_compute(sp_data *sp, sp_randh *p, SPFLOAT *in, SPFLOAT *out)
{
    if(p->counter == 0) {
        p->val = p->min + ((SPFLOAT) sp_rand(sp) / SP_RANDMAX) * (p->max - p->min);
        
        if(p->freq == 0) {
            p->dur = 1;
        } else {
            p->dur = (sp->sr / p->freq) + 1; 
        }

        *out = p->val;
    } else {
        *out = p->val;
    }
    p->counter = (p->counter + 1) % p->dur;
    return SP_OK;
}
