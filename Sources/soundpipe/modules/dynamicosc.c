#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"
#include <stdbool.h>

int sp_dynamicosc_create(sp_dynamicosc **dynamicosc)
{
    *dynamicosc = malloc(sizeof(sp_dynamicosc));
    return SP_OK;
}

int sp_dynamicosc_destroy(sp_dynamicosc **dynamicosc)
{
    free(*dynamicosc);
    return SP_NOT_OK;
}

int sp_dynamicosc_init(sp_data *sp, sp_dynamicosc *dynamicosc, SPFLOAT iphs)
{
    dynamicosc->freq = 440.0;
    dynamicosc->amp = 0.2;
    dynamicosc->iphs = fabs(iphs);
    dynamicosc->inc = 0;
    if (dynamicosc->iphs >= 0){
        dynamicosc->lphs = ((int32_t)(dynamicosc->iphs * SP_FT_MAXLEN)) & SP_FT_PHMASK;
    }

    return SP_OK;
}

int sp_dynamicosc_compute(sp_data *sp, sp_dynamicosc *dynamicosc, sp_ftbl *ft_other, SPFLOAT *in, SPFLOAT *out, bool shouldInc)
{
    sp_ftbl *ftp;
    SPFLOAT amp, cps, fract, v1, v2, *ft;
    int32_t phs, lobits;
    int32_t pos;
    SPFLOAT sicvt = ft_other->sicvt;

    ftp = ft_other;
    lobits = ft_other->lobits;
    amp = dynamicosc->amp;
    cps = dynamicosc->freq;
    phs = dynamicosc->lphs;
    ft = ftp->tbl;
    
    dynamicosc->inc = (int32_t)lrintf(cps * sicvt); // rounds to nearest integer

    fract = ((phs) & ftp->lomask) * ftp->lodiv;
    pos = phs>>lobits;
    v1 = *(ft + pos);
    v2 = *(ft + ((pos + 1) % ftp->size));
    *out = (v1 + (v2 - v1) * fract) * amp;
    phs += dynamicosc->inc;
    phs &= SP_FT_PHMASK;

    if (shouldInc) {
        dynamicosc->lphs = phs;
    }
    return SP_OK;
}
