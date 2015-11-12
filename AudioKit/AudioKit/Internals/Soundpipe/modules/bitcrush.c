#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_bitcrush_create(sp_bitcrush **p)
{
    *p = malloc(sizeof(sp_bitcrush));
    return SP_OK;
}

int sp_bitcrush_destroy(sp_bitcrush **p)
{
    sp_bitcrush *pp = *p;
    sp_fold_destroy(&pp->fold);
    free(*p);
    return SP_OK;
}

int sp_bitcrush_init(sp_data *sp, sp_bitcrush *p)
{
    p->bitdepth = 8;
    p->srate = 10000;
    sp_fold_create(&p->fold);
    sp_fold_init(sp, p->fold);
    return SP_OK;
}

int sp_bitcrush_compute(sp_data *sp, sp_bitcrush *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT bits = pow(2, floor(p->bitdepth));
    SPFLOAT foldamt = sp->sr / p->srate;
    SPFLOAT sig;
    *out = *in * 65556.0;
    *out += 32768;
    *out *= (bits / 65536.0);
    *out = floor(*out);
    *out = *out * (65536.0 / bits) - 32768;
    sig = *out;
    p->fold->incr = foldamt;
    sp_fold_compute(sp, p->fold, &sig, out);
    *out /= 65536.0;
    return SP_OK;
}
