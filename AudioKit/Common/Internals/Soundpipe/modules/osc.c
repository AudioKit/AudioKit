/*
 * Osc
 *
 * This code has been extracted from the Csound opcode "oscili".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Barry Vercoe, John FFitch, Robin Whittle
 * Year: 1991
 * Location: OOps/ugens2.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_osc_create(sp_osc **osc)
{
    *osc = malloc(sizeof(sp_osc));
    return SP_OK;
}

int sp_osc_destroy(sp_osc **osc)
{
    free(*osc);
    return SP_NOT_OK;
}

int sp_osc_init(sp_data *sp, sp_osc *osc, sp_ftbl *ft, SPFLOAT iphs)
{
    osc->freq = 440.0;
    osc->amp = 0.2;
    osc->tbl = ft;
    osc->iphs = fabs(iphs);
    osc->inc = 0;
    if (osc->iphs >= 0){
        osc->lphs = ((int32_t)(osc->iphs * SP_FT_MAXLEN)) & SP_FT_PHMASK;
    }
    return SP_OK;
}

int sp_osc_compute(sp_data *sp, sp_osc *osc, SPFLOAT *in, SPFLOAT *out)
{
    sp_ftbl *ftp;
    SPFLOAT amp, cps, fract, v1, v2, *ftab, *ft;
    int32_t phs, lobits;
    SPFLOAT sicvt = osc->tbl->sicvt;

    ftp = osc->tbl;
    lobits = osc->tbl->lobits;
    amp = osc->amp;
    cps = osc->freq;
    phs = osc->lphs;
    ft = osc->tbl->tbl;
    
    osc->inc = (int32_t)lrintf(cps * sicvt);

    fract = ((phs) & ftp->lomask) * ftp->lodiv;
    ftab = ft + (phs >> lobits);
    v1 = ftab[0];
    v2 = ftab[1];
    *out = (v1 + (v2 - v1) * fract) * amp;
    phs += osc->inc;
    phs &= SP_FT_PHMASK;

    osc->lphs = phs;
    return SP_OK;
}
